
locals {
  prefix       = var.prefix == null ? "" : "${var.prefix}-"
  is_mysql     = can(regex("^MYSQL", var.database_version))
  has_replicas = try(length(var.replicas) > 0, false)
  is_regional  = var.availability_type == "REGIONAL" ? true : false
  is_postgres  = can(regex("^POSTGRES", var.database_version))
  # Enable backup if the user asks for it or if the user is deploying
  # MySQL in HA configuration (regional or with specified replicas)
  enable_backup   = var.backup_configuration.enabled || (local.is_mysql && local.has_replicas) || (local.is_mysql && local.is_regional)
  enable_insights = var.insights_configuration.enabled
  users = {
    for k, v in coalesce(var.users, {}) :
    k =>
    local.is_mysql ?
    {
      name     = coalesce(v.type, "BUILT_IN") == "BUILT_IN" ? split("@", k)[0] : k
      host     = coalesce(v.type, "BUILT_IN") == "BUILT_IN" ? try(split("@", k)[1], null) : null
      password = coalesce(v.type, "BUILT_IN") == "BUILT_IN" ? try(random_password.passwords[k].result, v.password) : null
      type     = coalesce(v.type, "BUILT_IN")
      } : {
      name     = local.is_postgres ? try(trimsuffix(k, ".gserviceaccount.com"), k) : k
      host     = null
      password = coalesce(v.type, "BUILT_IN") == "BUILT_IN" ? try(random_password.passwords[k].result, v.password) : null
      type     = coalesce(v.type, "BUILT_IN")
    }
  }
  users_access = flatten([
    for k, v in coalesce(var.users, {}) : [
      for db in toset(v.access_to_db) : {
        database = db
        username = k
        password = local.users[k].password
      }
    ]
  ])

}

resource "google_sql_database_instance" "primary" {
  provider            = google-beta
  project             = var.project_id
  name                = "${local.prefix}${var.name}"
  region              = var.region
  database_version    = var.database_version
  encryption_key_name = var.encryption_key_name
  root_password       = var.root_password

  settings {
    tier                        = var.tier
    edition                     = "ENTERPRISE"
    disk_autoresize             = var.disk_size == null
    disk_size                   = var.disk_size
    disk_type                   = var.disk_type
    availability_type           = var.availability_type
    deletion_protection_enabled = var.deletion_protection
    user_labels                 = var.labels
    maintenance_window {
      day          = var.maintenance_window.day
      hour         = var.maintenance_window.hour
      update_track = var.maintenance_window.update_track
    }
    ip_configuration {
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects =concat([var.project_id],[var.shared_vpc_project])
      }
      ipv4_enabled                                  = false
      enable_private_path_for_google_cloud_services = var.enable_private_path_for_google_cloud_services
    }
    dynamic "backup_configuration" {
      for_each = local.enable_backup ? { 1 = 1 } : {}
      content {
        enabled = true
        binary_log_enabled = (
          local.is_mysql
          ? var.backup_configuration.binary_log_enabled || local.has_replicas || local.is_regional
          : null
        )
        start_time                     = var.backup_configuration.start_time
        location                       = var.backup_configuration.location
        transaction_log_retention_days = var.backup_configuration.log_retention_days
        point_in_time_recovery_enabled = var.backup_configuration.point_in_time_recovery_enabled
        backup_retention_settings {
          retained_backups = var.backup_configuration.retention_count
          retention_unit   = "COUNT"
        }
      }
    }
    dynamic "insights_config" {
      for_each = local.enable_insights ? { 1 = 1 } : {}
      content {
        query_insights_enabled  = var.insights_configuration.enabled
        query_string_length     = var.insights_configuration.query_string_length
        record_application_tags = var.insights_configuration.record_application_tags
        record_client_address   = var.insights_configuration.record_client_address
        query_plans_per_minute  = var.insights_configuration.query_plans_per_minute
      }
    }
    dynamic "database_flags" {
      for_each = var.flags != null ? var.flags : {}
      iterator = flag
      content {
        name  = flag.key
        value = flag.value
      }
    }
  }
  deletion_protection = var.deletion_protection
}

resource "google_sql_database_instance" "replicas" {
  provider             = google-beta
  for_each             = local.has_replicas ? var.replicas : {}
  project              = var.project_id
  name                 = "${local.prefix}${each.key}"
  region               = each.value.region
  database_version     = each.value.database_version != null ? each.value.database_version : var.database_version
  encryption_key_name  = each.value.encryption_key_name
  master_instance_name = google_sql_database_instance.primary.name

  settings {
    tier            = var.tier
    disk_autoresize = var.disk_size == null
    disk_size       = var.disk_size
    disk_type       = var.disk_type
    user_labels     = var.labels

    ip_configuration {
      ipv4_enabled       = var.ipv4_enabled
      private_network    = var.network
      allocated_ip_range = var.allocated_ip_ranges.replica
      dynamic "authorized_networks" {
        for_each = var.authorized_networks != null ? var.authorized_networks : {}
        iterator = network
        content {
          name  = network.key
          value = network.value
        }
      }
    }

    dynamic "database_flags" {
      for_each = var.flags != null ? var.flags : {}
      iterator = flag
      content {
        name  = flag.key
        value = flag.value
      }
    }
  }
  deletion_protection = var.deletion_protection
}

resource "google_sql_database" "databases" {
  for_each = var.databases != null ? toset(var.databases) : toset([])
  project  = var.project_id
  instance = google_sql_database_instance.primary.name
  name     = each.key
}

resource "random_password" "passwords" {
  for_each = {
    for k, v in coalesce(var.users, {}) :
    k => v
    if v.password == null
  }
  length           = 16
  special          = true
  override_special = each.value.override_special
}

resource "google_sql_user" "users" {
  for_each = local.users
  project  = var.project_id
  instance = google_sql_database_instance.primary.name
  name     = each.value.name
  host     = each.value.host
  password = each.value.password
  type     = each.value.type
}

resource "google_sql_user" "iam_users" {
  for_each = {
    for index, user in var.iam_users : user.email => user
  }
  project  = var.project_id
  name     = each.key # The email address as the name
  instance = google_sql_database_instance.primary.name
  type     = each.value.type
}

resource "google_sql_ssl_cert" "client_certificates" {
  for_each = (
    var.ssl.client_certificates != null
    ? toset(var.ssl.client_certificates)
    : toset([])
  )
  provider    = google-beta
  project     = var.project_id
  instance    = google_sql_database_instance.primary.name
  common_name = each.key
}

resource "google_compute_address" "default" {
  name         = "${var.name}-psc-ip"
  region       = var.region
  project      = var.shared_vpc_project
  address_type = "INTERNAL"
  subnetwork   = var.psc_subnet_name
}

data "google_compute_address" "psc" {
  name       = "${var.name}-psc-ip"
  project    = var.shared_vpc_project
  region     = var.region
  depends_on = [google_compute_address.default]
}

resource "google_compute_forwarding_rule" "default" {
  name                    = "${var.name}-psc-sql-endpoint"
  network                 = var.psc_vpc_name
  project                 = var.shared_vpc_project
  region                  = var.region
  ip_address              = google_compute_address.default.self_link
  load_balancing_scheme   = ""
  target                  = google_sql_database_instance.primary.psc_service_attachment_link
  allow_psc_global_access = true
}

resource "google_secret_manager_regional_secret" "secret" {
  for_each = {
    for ua in local.users_access : "${local.prefix}${var.name}-${ua.username}-${ua.database}" => ua
  }

  project   = var.project_id
  location = var.region
  secret_id = "${local.prefix}${var.name}-${each.value.username}-${each.value.database}"
  depends_on = [google_sql_user.users]
}

resource "google_secret_manager_regional_secret_version" "secret_version_basic" {
  for_each = {
    for ua in local.users_access : "${local.prefix}${var.name}-${ua.username}-${ua.database}" => ua
  }
  secret = google_secret_manager_regional_secret.secret["${local.prefix}${var.name}-${each.value.username}-${each.value.database}"].id

  secret_data = local.is_postgres ? (
    ":Database=${each.value.database};Username=${each.value.username};Password=${each.value.password};SSL Mode=Require;Trust Server Certificate=true"
    ) : local.is_mysql ? (
    "mysql://${each.value.username}:${each.value.password}@:3306/${each.value.database}"
    ) : (
    "Database=${each.value.database};Username=${each.value.username};Password=${each.value.password};SSL Mode=Require;Trust Server Certificate=true"
  )
}

resource "google_secret_manager_secret" "postgre_ssl_ca" {
  for_each = (
    var.ssl.client_certificates != null
    ? toset(var.ssl.client_certificates)
    : toset([])
  )
  project   = var.project_id
  secret_id = "${local.prefix}${var.name}-postgre-ssl-ca"
  replication {
    auto {}
  }
  depends_on = [google_sql_ssl_cert.client_certificates]
}

resource "google_secret_manager_secret" "postgre_ssl_crt" {
  for_each = (
    var.ssl.client_certificates != null
    ? toset(var.ssl.client_certificates)
    : toset([])
  )
  project   = var.project_id
  secret_id = "${local.prefix}${var.name}-postgre-ssl-crt"
  replication {
    auto {}
  }
  depends_on = [google_sql_ssl_cert.client_certificates]
}

resource "google_secret_manager_secret" "postgre_ssl_key" {
  for_each = (
    var.ssl.client_certificates != null
    ? toset(var.ssl.client_certificates)
    : toset([])
  )
  project   = var.project_id
  secret_id = "${local.prefix}${var.name}-postgre-ssl-key"
  replication {
    auto {}
  }
  depends_on = [google_sql_ssl_cert.client_certificates]
}

resource "google_secret_manager_secret_version" "postgre_ssl_ca" {
  for_each = (
    var.ssl.client_certificates != null
    ? toset(var.ssl.client_certificates)
    : toset([])
  )
  secret = google_secret_manager_secret.postgre_ssl_ca[each.key].id

  secret_data = google_sql_ssl_cert.client_certificates[each.key].server_ca_cert
}

resource "google_secret_manager_secret_version" "postgre_ssl_crt" {
  for_each = (
    var.ssl.client_certificates != null
    ? toset(var.ssl.client_certificates)
    : toset([])
  )
  secret = google_secret_manager_secret.postgre_ssl_crt[each.key].id

  secret_data = google_sql_ssl_cert.client_certificates[each.key].cert
}

resource "google_secret_manager_secret_version" "postgre_ssl_key" {
  for_each = (
    var.ssl.client_certificates != null
    ? toset(var.ssl.client_certificates)
    : toset([])
  )
  secret = google_secret_manager_secret.postgre_ssl_key[each.key].id

  secret_data = google_sql_ssl_cert.client_certificates[each.key].private_key
}

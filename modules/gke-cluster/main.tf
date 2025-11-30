locals {
  workload_identity_config = !var.enable_workload_identity ? [] : var.identity_namespace == null ? [{
    identity_namespace = "${var.project}.svc.id.goog" }] : [{ identity_namespace = var.identity_namespace
  }]
  cluster_name       = "gke-${var.env}-${var.name}${var.sufix}"
  latest_version     = data.google_container_engine_versions.location.latest_master_version
  kubernetes_version = var.kubernetes_version != "latest" ? var.kubernetes_version : local.latest_version
}

data "google_project" "project" {
  project_id = var.project
}

resource "google_project_iam_member" "service_account_roles" {
  count   = var.enable_secrets_database_encryption != false ? 1 : 0
  project = var.project
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create secret key for Cluster database encryption
# ---------------------------------------------------------------------------------------------------------------------
resource "google_kms_key_ring" "keyring" {
  count    = var.enable_secrets_database_encryption ? 1 : 0
  name     = "keyring-${var.env}-${var.name}${var.sufix}"
  location = var.region
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "cluster_encryption_key" {
  count    = var.enable_secrets_database_encryption ? 1 : 0
  name     = "encryption-key-${var.env}-${var.name}${var.sufix}"
  key_ring = google_kms_key_ring.keyring[0].id
  lifecycle {
    prevent_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Create the GKE Cluster
# We want to make a cluster with no node pools, and manage them all with the fine-grained google_container_node_pool resource
# ---------------------------------------------------------------------------------------------------------------------

resource "google_container_cluster" "cluster" {
  name                     = local.cluster_name
  description              = var.description
  node_locations           = var.node_locations
  project                  = var.project
  location                 = var.location
  network                  = var.network
  subnetwork               = var.subnetwork
  min_master_version       = local.kubernetes_version
  enable_l4_ilb_subsetting = var.enable_l4_ilb_subsetting
  monitoring_config {
    enable_components = toset(compact([
      # System metrics is the minimum requirement if any other metrics are enabled.
      # This is checked by input var validation.
      var.monitoring_config.enable_system_metrics ? "SYSTEM_COMPONENTS" : null,
      # Control plane metrics
      var.monitoring_config.enable_api_server_metrics ? "APISERVER" : null,
      var.monitoring_config.enable_controller_manager_metrics ? "CONTROLLER_MANAGER" : null,
      var.monitoring_config.enable_scheduler_metrics ? "SCHEDULER" : null,
      # Kube state metrics
      var.monitoring_config.enable_daemonset_metrics ? "DAEMONSET" : null,
      var.monitoring_config.enable_deployment_metrics ? "DEPLOYMENT" : null,
      var.monitoring_config.enable_hpa_metrics ? "HPA" : null,
      var.monitoring_config.enable_pod_metrics ? "POD" : null,
      var.monitoring_config.enable_statefulset_metrics ? "STATEFULSET" : null,
      var.monitoring_config.enable_storage_metrics ? "STORAGE" : null,
      var.monitoring_config.enable_cadvisor_metrics ? "CADVISOR" : null,
    ]))
    managed_prometheus {
      enabled = var.monitoring_config.enable_managed_prometheus
    }
    dynamic "advanced_datapath_observability_config" {
      for_each = (
        var.monitoring_config.advanced_datapath_observability == null
        ? []
        : [""]
      )
      content {
        enable_metrics = (
          var.monitoring_config.advanced_datapath_observability.enable_metrics
        )
        enable_relay = (
          var.monitoring_config.advanced_datapath_observability.enable_relay
        )
      }
    }
  }
  # Whether to enable legacy Attribute-Based Access Control (ABAC). RBAC has significant security advantages over ABAC.
  enable_legacy_abac = var.enable_legacy_abac

  # The API requires a node pool or an initial count to be defined; that initial count creates the
  # "default node pool" with that # of nodes.
  # So, we need to set an initial_node_count of 1. This will make a default node
  # pool with server-defined defaults that Terraform will immediately delete as
  # part of Create. This leaves us in our desired state- with a cluster master
  # with no node pools.
  remove_default_node_pool = true

  initial_node_count    = 1
  enable_shielded_nodes = var.enable_shielded_nodes

  secret_manager_config {
    enabled = true
  }
  # If we have an alternative default service account to use, set on the node_config so that the default node pool can
  # be created successfully.
  dynamic "node_config" {
    # Ideally we can do `for_each = var.alternative_default_service_account != null ? [object] : []`, but due to a
    # terraform bug, this doesn't work. See https://github.com/hashicorp/terraform/issues/21465. So we simulate it using
    # a for expression.
    for_each = [
      for x in [var.alternative_default_service_account] : x if var.alternative_default_service_account != null
    ]

    content {
      service_account = node_config.value
    }
  }

  # ip_allocation_policy.use_ip_aliases defaults to true, since we define the block `ip_allocation_policy`
  ip_allocation_policy {
    # Choose the range, but let GCP pick the IPs within the range
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.service_secondary_range_name

    #     # Enable IPv6 with these settings
    stack_type = "IPV4"
  }

  # We can optionally control access to the cluster
  # See https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters
  private_cluster_config {
    enable_private_endpoint     = var.disable_public_endpoint
    enable_private_nodes        = var.enable_private_nodes
    private_endpoint_subnetwork = var.subnetwork
    master_ipv4_cidr_block      = var.master_ipv4_cidr_block
  }
  release_channel {
    channel = "REGULAR"
  }
  dns_config {
    cluster_dns       = "CLOUD_DNS"
    cluster_dns_scope = "CLUSTER_SCOPE"
  }
  addons_config {
    http_load_balancing {
      disabled = !var.http_load_balancing
    }

    horizontal_pod_autoscaling {
      disabled = !var.horizontal_pod_autoscaling
    }
  }
  datapath_provider = var.enable_dataplane_v2 ? "ADVANCED_DATAPATH" : "DATAPATH_PROVIDER_UNSPECIFIED"
  vertical_pod_autoscaling {
    enabled = var.enable_vertical_pod_autoscaling
  }

  dynamic "gateway_api_config" {
    for_each = var.enable_gateway_api ? [""] : []
    content {
      channel = "CHANNEL_STANDARD"
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = lookup(master_authorized_networks_config.value, "cidr_blocks", [])
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = lookup(cidr_blocks.value, "display_name", null)
        }
      }
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_start_time
    }
  }

  lifecycle {
    ignore_changes = [
      # Since we provide `remove_default_node_pool = true`, the `node_config` is only relevant for a valid construction of
      # the GKE cluster in the initial creation. As such, any changes to the `node_config` should be ignored.
      node_config,
    ]
  }

  # If var.gsuite_domain_name is non-empty, initialize the cluster with a G Suite security group
  dynamic "authenticator_groups_config" {
    for_each = [
      for x in [var.gsuite_domain_name] : x if var.gsuite_domain_name != null
    ]

    content {
      security_group = "gke-security-groups@${authenticator_groups_config.value}"
    }
  }

  # If var.secrets_encryption_kms_key is non-empty, create ´database_encryption´ -block to encrypt secrets at rest in etcd
  dynamic "database_encryption" {
    for_each = [
      for x in [var.enable_secrets_database_encryption] : x if var.enable_secrets_database_encryption != false
    ]

    content {
      state    = "ENCRYPTED"
      key_name = google_kms_crypto_key.cluster_encryption_key[0].id
    }
  }

  dynamic "control_plane_endpoints_config" {
    for_each = var.access_config_dns_access == true ? [""] : []
    content {
      dns_endpoint_config {
        allow_external_traffic = true
      }
    }
  }

  dynamic "workload_identity_config" {
    for_each = local.workload_identity_config

    content {
      workload_pool = "${var.project}.svc.id.goog"
    }
  }

  resource_labels = var.resource_labels
  depends_on = [ 
    google_project_iam_member.gke_host_agent,
    google_compute_subnetwork_iam_member.member
  ]
}

resource "google_project_iam_member" "gke_host_agent" {
  count   = var.shared_vpc_project != null ? 1 : 0
  project = var.shared_vpc_project
  role    = "roles/container.hostServiceAgentUser"
  member  = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_compute_subnetwork_iam_member" "member" {
  count   = var.shared_vpc_project != null ? 1 : 0
  subnetwork = var.subnetwork
  project    = var.shared_vpc_project # This project var is for the subnetwork IAM, potentially different from service projects
  region     = var.region
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${module.gke_service_account.email}"
}

resource "google_compute_subnetwork_iam_member" "host" {
  count   = var.shared_vpc_project != null ? 1 : 0
  subnetwork = var.subnetwork
  project    = var.shared_vpc_project # This project var is for the subnetwork IAM, potentially different from service projects
  region     = var.region
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}


# Get available master versions in our location to determine the latest version
data "google_container_engine_versions" "location" {
  location = var.location
  project  = var.project
}

resource "google_container_node_pool" "node_pool_additional" {
  for_each = var.node_pools
  provider = google-beta
  name     = each.value.name
  project  = var.project
  location = var.location
  cluster  = local.cluster_name
  version  = each.value.nodepool_version != "" ? each.value.nodepool_version : var.kubernetes_nodes_version

  dynamic "autoscaling" {
    for_each = (
      try(each.value.nodepool_config.autoscaling, null) != null
      &&
      !try(each.value.nodepool_config.autoscaling.use_total_nodes, false)
      ? [""] : []
    )
    content {
      location_policy = try(each.value.nodepool_config.autoscaling.location_policy, null)
      max_node_count  = try(each.value.nodepool_config.max_node_count, null)
      min_node_count  = try(each.value.nodepool_config.min_node_count, null)
    }
  }
  dynamic "autoscaling" {
    for_each = (
      try(each.value.nodepool_config.autoscaling.use_total_nodes, false) ? [""] : []
    )
    content {
      location_policy      = try(each.value.nodepool_config.autoscaling.location_policy, null)
      total_max_node_count = try(each.value.nodepool_config.autoscaling.max_node_count, null)
      total_min_node_count = try(each.value.nodepool_config.autoscaling.min_node_count, null)
    }
  }
  dynamic "management" {
    for_each = try(each.value.nodepool_config.management, null) != null ? [""] : []
    content {
      auto_repair  = try(each.value.nodepool_config.management.auto_repair, null)
      auto_upgrade = try(each.value.nodepool_config.management.auto_upgrade, null)
    }
  }
  dynamic "upgrade_settings" {
    for_each = try(each.value.nodepool_config.upgrade_settings, null) != null ? [""] : []
    content {
      max_surge       = try(each.value.nodepool_config.upgrade_settings.max_surge, null)
      max_unavailable = try(each.value.nodepool_config.upgrade_settings.max_unavailable, null)
    }
  }
  node_locations = each.value.nodepool_locations != "" ? each.value.nodepool_locations : var.node_locations
  node_config {
    image_type   = each.value.nodepool_image_type != "" ? each.value.nodepool_image_type : "COS_CONTAINERD"
    machine_type = each.value.nodepool_machine_type != "" ? each.value.nodepool_machine_type : var.machine_type
    dynamic "guest_accelerator" {
      for_each = each.value.guest_accelerator != null ? each.value.guest_accelerator : []

      content {
        type  = guest_accelerator.value.type
        count = guest_accelerator.value.count
      }
    }
    labels = try(each.value.nodepool_config.labels, null)

    # Add a private tag to the instances. See the network access tier table for full details:
    # https://github.com/gruntwork-io/terraform-google-network/tree/master/modules/vpc-network#access-tier
    tags = [
      var.private_tag,
      "private-pool",
    ]
    dynamic "taint" {
      for_each = each.value.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
    disk_size_gb    = each.value.disk_size_gb
    disk_type       = each.value.disk_type
    preemptible     = each.value.nodepool_preemptible != "" ? each.value.nodepool_preemptible : var.preemptible
    spot            = each.value.nodepool_spot != "" ? each.value.nodepool_spot : var.spot
    service_account = module.gke_service_account.email

    oauth_scopes = var.oauth_scopes
  }
  max_pods_per_node = each.value.max_pods_per_node
  lifecycle {
    ignore_changes = [initial_node_count]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
  depends_on = [google_container_cluster.cluster]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CUSTOM SERVICE ACCOUNT TO USE WITH THE GKE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "gke_service_account" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  source                = "github.com/gruntwork-io/terraform-google-gke.git//modules/gke-service-account?ref=v0.3.8"
  name                  = "${var.cluster_service_account_name}${var.sufix}"
  project               = var.project
  description           = var.cluster_service_account_description
  service_account_roles = var.service_account_roles
}

resource "google_project_iam_member" "extra_sa_binding" {
  count   = var.artifact_registry_project != null ? 1 : 0
  project = var.artifact_registry_project
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${module.gke_service_account.email}"
}

resource "kubernetes_storage_class" "hyperdisk_balanced" {
  metadata {
    name = "hyperdisk-balanced"
  }
  storage_provisioner = "pd.csi.storage.gke.io"
  reclaim_policy      = "Delete"
  parameters = {
    type = "hyperdisk-balanced",
  }
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  depends_on             = [google_container_cluster.cluster]
}

resource "kubernetes_annotations" "standard" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "standard"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
}

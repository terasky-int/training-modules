locals {
  all_intances = merge(
    { primary = google_sql_database_instance.primary },
    google_sql_database_instance.replicas
  )
}

output "connection_name" {
  description = "Connection name of the primary instance."
  value       = google_sql_database_instance.primary.connection_name
}

output "connection_names" {
  description = "Connection names of all instances."
  value = {
    for id, instance in local.all_intances :
    id => instance.connection_name
  }
}

output "id" {
  description = "ID of the primary instance."
  value       = google_sql_database_instance.primary.private_ip_address
}

output "ids" {
  description = "IDs of all instances."
  value = {
    for id, instance in local.all_intances :
    id => instance.id
  }
}

output "instances" {
  description = "Cloud SQL instance resources."
  value       = local.all_intances
  sensitive   = true
}

output "ip" {
  description = "IP address of the primary instance."
  value       = google_sql_database_instance.primary.private_ip_address
}

output "ips" {
  description = "IP addresses of all instances."
  value = {
    for id, instance in local.all_intances :
    id => instance.private_ip_address
  }
}

output "name" {
  description = "Name of the primary instance."
  value       = google_sql_database_instance.primary.name
}

output "names" {
  description = "Names of all instances."
  value = {
    for id, instance in local.all_intances :
    id => instance.name
  }
}

output "self_link" {
  description = "Self link of the primary instance."
  value       = google_sql_database_instance.primary.self_link
}

output "self_links" {
  description = "Self links of all instances."
  value = {
    for id, instance in local.all_intances :
    id => instance.self_link
  }
}

output "user_passwords" {
  description = "Map of containing the password of all users created through terraform."
  value = {
    for name, user in google_sql_user.users :
    name => user.password
  }
  sensitive = true
}

output "psc_service_attachment_link" {
  description = "The URI that points to the service attachment of the instance."
  value       = google_sql_database_instance.primary.psc_service_attachment_link
}

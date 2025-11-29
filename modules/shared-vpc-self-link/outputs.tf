output "network" {
  description = "VPC network self link"
  value       = data.google_compute_network.shared_vpc.self_link
}

output "subnetwork" {
  description = "VPC subnetwork self link"
  value       = data.google_compute_subnetwork.subnetwork.self_link
}

output "network_id" {
  description = "VPC network id"
  value       = data.google_compute_network.shared_vpc.id
}

output "subnetwork_id" {
  description = "VPC subnetwork id"
  value       = data.google_compute_subnetwork.subnetwork.id
}

output "seconday_pods_name" {
  description = "VPC subnetwork secondary range name for pods"
  value       = local.cluster_range
}

output "seconday_services_name" {
  description = "VPC subnetwork secondary range name for services"
  value       = local.services_range
}

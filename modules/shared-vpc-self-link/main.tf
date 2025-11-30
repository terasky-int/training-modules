data "google_compute_network" "shared_vpc" {
  name = var.network_name
  project = var.project
}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.subnet_name
  region  = var.region
  project = var.project

}

locals {
  cluster_range  = [for i in data.google_compute_subnetwork.subnetwork.secondary_ip_range : i.range_name if length(regexall(".*pods", i.range_name)) > 0][0]
  services_range = [for i in data.google_compute_subnetwork.subnetwork.secondary_ip_range : i.range_name if length(regexall(".*svc", i.range_name)) > 0][0]
}

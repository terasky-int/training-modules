resource "google_compute_subnetwork_iam_member" "member" {
  for_each = { for k, v in var.members_by_subnetwork_and_role : "${v.subnetwork}-${v.role}-${v.member}" => v }

  subnetwork = each.value.subnetwork
  project    = var.host_project # This project var is for the subnetwork IAM, potentially different from service projects
  region     = each.value.region
  role       = each.value.role
  member     = each.value.member
}

resource "google_compute_shared_vpc_service_project" "service_project" {
  for_each = { for sp in toset(var.service_projects) : sp => sp }

  host_project    = var.host_project
  service_project = each.key
}

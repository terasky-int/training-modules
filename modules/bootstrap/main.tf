locals {

  parent = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
  org_admins_org_iam_permissions = var.org_policy_admin_role == true ? [
    "roles/orgpolicy.policyAdmin", "roles/resourcemanager.organizationAdmin", "roles/billing.user"
  ] : ["roles/resourcemanager.organizationAdmin", "roles/billing.user"]

}

resource "google_folder" "bootstrap" {
  display_name        = var.bootstrap_folder_name != "" ? var.bootstrap_folder_name : "${var.folder_prefix}-bootstrap"
  parent              = local.parent
  deletion_protection = var.folder_deletion_protection
}

module "seed_bootstrap" {
  source  = "./seed_bootstrap"
  org_id                         = var.org_id
  folder_id                      = google_folder.bootstrap.id
  project_id                     = "${var.project_prefix}-seed"
  state_bucket_name              = "${var.bucket_prefix}${var.project_prefix}-seed-tfstate"
  force_destroy                  = var.bucket_force_destroy
  billing_account                = var.billing_account
  group_org_admins               = var.groups.required_groups.group_org_admins
  group_billing_admins           = var.groups.required_groups.group_billing_admins
  default_region                 = var.default_region
  org_project_creators           = var.org_project_creators
  sa_enable_impersonation        = true
  create_terraform_sa            = false
  parent_folder                  = var.parent_folder == "" ? "" : local.parent
  org_admins_org_iam_permissions = local.org_admins_org_iam_permissions
  # project_prefix                 = var.project_prefix
  encrypt_gcs_bucket_tfstate = false
  # key_rotation_period            = "7776000s"
  kms_prevent_destroy     = !var.bucket_tfstate_kms_force_destroy
  project_deletion_policy = var.project_deletion_policy

  project_labels = {
    environment      = "bootstrap"
    application_name = "seed-bootstrap"
  }

  activate_apis = [
    "iam.googleapis.com",
    "storage-api.googleapis.com",
    "orgpolicy.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "logging.googleapis.com", #Cloud Logging API

  ]

  sa_org_iam_permissions = []
}

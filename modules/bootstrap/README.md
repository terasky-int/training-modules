# bootstrap

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.33.0, < 7.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.47.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_seed_bootstrap"></a> [seed\_bootstrap](#module\_seed\_bootstrap) | terraform-google-modules/bootstrap/google | ~> 11.0 |

## Resources

| Name | Type |
|------|------|
| [google_folder.bootstrap](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | The ID of the billing account to associate projects with. | `string` | n/a | yes |
| <a name="input_bootstrap_folder_name"></a> [bootstrap\_folder\_name](#input\_bootstrap\_folder\_name) | Custom name for bootstrap folder. If not provided, will use var.folder\_prefix-bootstrap' | `string` | `""` | no |
| <a name="input_bucket_force_destroy"></a> [bucket\_force\_destroy](#input\_bucket\_force\_destroy) | When deleting a bucket, this boolean option will delete all contained objects. If false, Terraform will fail to delete buckets which contain objects. | `bool` | `false` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | Name prefix to use for state bucket created. | `string` | `"bkt"` | no |
| <a name="input_bucket_tfstate_kms_force_destroy"></a> [bucket\_tfstate\_kms\_force\_destroy](#input\_bucket\_tfstate\_kms\_force\_destroy) | When deleting a bucket, this boolean option will delete the KMS keys used for the Terraform state bucket. | `bool` | `false` | no |
| <a name="input_default_region"></a> [default\_region](#input\_default\_region) | Default region to create resources where applicable. | `string` | `"us-central1"` | no |
| <a name="input_folder_deletion_protection"></a> [folder\_deletion\_protection](#input\_folder\_deletion\_protection) | Prevent Terraform from destroying or recreating the folder. | `string` | `true` | no |
| <a name="input_folder_prefix"></a> [folder\_prefix](#input\_folder\_prefix) | Name prefix to use for folders created. Should be the same in all steps. | `string` | `"fldr"` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | Contain the details of the Groups to be created. | <pre>object({<br>    create_required_groups = optional(bool, false)<br>    create_optional_groups = optional(bool, false)<br>    billing_project        = optional(string, null)<br>    required_groups = object({<br>      group_org_admins     = string<br>      group_billing_admins = string<br>      # billing_data_users   = string<br>      # audit_data_users     = string<br>    })<br>    optional_groups = optional(object({<br>      gcp_security_reviewer    = optional(string, "")<br>      gcp_network_viewer       = optional(string, "")<br>      gcp_scc_admin            = optional(string, "")<br>      gcp_global_secrets_admin = optional(string, "")<br>      gcp_kms_admin            = optional(string, "")<br>    }), {})<br>  })</pre> | n/a | yes |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | GCP Organization ID | `string` | n/a | yes |
| <a name="input_org_policy_admin_role"></a> [org\_policy\_admin\_role](#input\_org\_policy\_admin\_role) | Additional Org Policy Admin role for admin group. You can use this for testing purposes. | `bool` | `false` | no |
| <a name="input_org_project_creators"></a> [org\_project\_creators](#input\_org\_project\_creators) | Additional list of members to have project creator role accross the organization. Prefix of group: user: or serviceAccount: is required. | `list(string)` | `[]` | no |
| <a name="input_parent_folder"></a> [parent\_folder](#input\_parent\_folder) | Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. | `string` | `""` | no |
| <a name="input_project_deletion_policy"></a> [project\_deletion\_policy](#input\_project\_deletion\_policy) | The deletion policy for the project created. | `string` | `"PREVENT"` | no |
| <a name="input_project_prefix"></a> [project\_prefix](#input\_project\_prefix) | Name prefix to use for projects created. Should be the same in all steps. Max size is 3 characters. | `string` | `"prj"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

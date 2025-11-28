# subnet-policy

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.49.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_shared_vpc_service_project.service_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_shared_vpc_service_project) | resource |
| [google_compute_subnetwork_iam_member.member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | The ID of the host project for Shared VPC. | `string` | n/a | yes |
| <a name="input_members_by_subnetwork_and_role"></a> [members\_by\_subnetwork\_and\_role](#input\_members\_by\_subnetwork\_and\_role) | A map of objects, each defining a subnetwork, region, role, and member to grant IAM access. | <pre>map(object({<br>    subnetwork = string<br>    region     = string<br>    role       = string<br>    member     = string<br>  }))</pre> | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | The ID of the project for the subnetwork IAM resources. If it is not provided, the provider project is used. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region of the subnetwork. | `string` | n/a | yes |
| <a name="input_service_projects"></a> [service\_projects](#input\_service\_projects) | A list of service project IDs to attach to the host project. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

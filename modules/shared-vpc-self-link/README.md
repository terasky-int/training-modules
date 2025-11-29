## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.30.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network.shared-vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_subnetwork.subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Network name | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project ID to host the database in. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to host the database in. | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Subnetwork name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network"></a> [network](#output\_network) | n/a |
| <a name="output_seconday_pods_name"></a> [seconday\_pods\_name](#output\_seconday\_pods\_name) | n/a |
| <a name="output_seconday_services_name"></a> [seconday\_services\_name](#output\_seconday\_services\_name) | n/a |
| <a name="output_subnetwork"></a> [subnetwork](#output\_subnetwork) | n/a |
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.1.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network.shared_vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_subnetwork.subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Network name | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project ID to host the database in. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to host the database in. | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Subnetwork name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network"></a> [network](#output\_network) | VPC network self link |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | VPC network id |
| <a name="output_seconday_pods_name"></a> [seconday\_pods\_name](#output\_seconday\_pods\_name) | VPC subnetwork secondary range name for pods |
| <a name="output_seconday_services_name"></a> [seconday\_services\_name](#output\_seconday\_services\_name) | VPC subnetwork secondary range name for services |
| <a name="output_subnetwork"></a> [subnetwork](#output\_subnetwork) | VPC subnetwork self link |
| <a name="output_subnetwork_id"></a> [subnetwork\_id](#output\_subnetwork\_id) | VPC subnetwork id |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

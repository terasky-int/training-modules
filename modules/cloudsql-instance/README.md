## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.47.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.47.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.47.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 4.47.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_sql_database_instance.primary](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_sql_database_instance) | resource |
| [google-beta_google_sql_database_instance.replicas](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_sql_database_instance) | resource |
| [google-beta_google_sql_ssl_cert.client_certificates](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_sql_ssl_cert) | resource |
| [google_compute_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_secret_manager_secret.postgre-ssl-ca](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.postgre-ssl-crt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.postgre-ssl-key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.postgre-ssl-ca](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_secret_manager_secret_version.postgre-ssl-crt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_secret_manager_secret_version.postgre-ssl-key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_secret_manager_secret_version.secret-version-basic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_sql_database.databases](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_user.iam_users](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [google_sql_user.users](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [random_password.passwords](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) | resource |
| [google_compute_address.psc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_address) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_ip_ranges"></a> [allocated\_ip\_ranges](#input\_allocated\_ip\_ranges) | (Optional)The name of the allocated ip range for the private ip CloudSQL instance. For example: "google-managed-services-default". If set, the instance ip will be created in the allocated range. The range name must comply with RFC 1035. Specifically, the name must be 1-63 characters long and match the regular expression a-z?. | <pre>object({<br>    primary = optional(string)<br>    replica = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_authorized_networks"></a> [authorized\_networks](#input\_authorized\_networks) | Map of NAME=>CIDR\_RANGE to allow to connect to the database(s). | `map(string)` | `null` | no |
| <a name="input_availability_type"></a> [availability\_type](#input\_availability\_type) | Availability type for the primary replica. Either `ZONAL` or `REGIONAL`. | `string` | `"ZONAL"` | no |
| <a name="input_backup_configuration"></a> [backup\_configuration](#input\_backup\_configuration) | Backup settings for primary instance. Will be automatically enabled if using MySQL with one or more replicas. | <pre>object({<br>    enabled                        = bool<br>    binary_log_enabled             = bool<br>    start_time                     = string<br>    location                       = string<br>    point_in_time_recovery_enabled = bool<br>    log_retention_days             = number<br>    retention_count                = number<br>  })</pre> | <pre>{<br>  "binary_log_enabled": true,<br>  "enabled": true,<br>  "location": null,<br>  "log_retention_days": 7,<br>  "point_in_time_recovery_enabled": true,<br>  "retention_count": 7,<br>  "start_time": "23:00"<br>}</pre> | no |
| <a name="input_database_version"></a> [database\_version](#input\_database\_version) | (Required) The MySQL, PostgreSQL or SQL Server version to use. Supported values include MYSQL\_5\_6, MYSQL\_5\_7, MYSQL\_8\_0, MYSQL\_8\_4, POSTGRES\_9\_6,POSTGRES\_10, POSTGRES\_11, POSTGRES\_12, POSTGRES\_13, POSTGRES\_14, POSTGRES\_15, POSTGRES\_16, POSTGRES\_17, SQLSERVER\_2017\_STANDARD, SQLSERVER\_2017\_ENTERPRISE, SQLSERVER\_2017\_EXPRESS, SQLSERVER\_2017\_WEB. SQLSERVER\_2019\_STANDARD, SQLSERVER\_2019\_ENTERPRISE, SQLSERVER\_2019\_EXPRESS, SQLSERVER\_2019\_WEB | `string` | n/a | yes |
| <a name="input_databases"></a> [databases](#input\_databases) | Databases to create once the primary instance is created. | `list(string)` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Allow terraform to delete instances. | `bool` | `false` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size in GB. Set to null to enable autoresize. | `number` | `null` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | The type of data disk: `PD_SSD` or `PD_HDD`. | `string` | `"PD_SSD"` | no |
| <a name="input_enable_private_path_for_google_cloud_services"></a> [enable\_private\_path\_for\_google\_cloud\_services](#input\_enable\_private\_path\_for\_google\_cloud\_services) | (Optional) Whether Google Cloud services such as BigQuery are allowed to access data in this Cloud SQL instance over a private IP connection. SQLSERVER database type is not supported. Default: false | `bool` | `false` | no |
| <a name="input_encryption_key_name"></a> [encryption\_key\_name](#input\_encryption\_key\_name) | The full path to the encryption key used for the CMEK disk encryption of the primary instance. | `string` | `null` | no |
| <a name="input_flags"></a> [flags](#input\_flags) | Map FLAG\_NAME=>VALUE for database-specific tuning. | `map(string)` | `null` | no |
| <a name="input_iam_users"></a> [iam\_users](#input\_iam\_users) | List of IAM users to create with their types and emails | <pre>list(object({<br>    email = string<br>    type  = string<br>  }))</pre> | `[]` | no |
| <a name="input_insights_configuration"></a> [insights\_configuration](#input\_insights\_configuration) | Enable Query insights | <pre>object({<br>    enabled                 = bool<br>    query_string_length     = number<br>    record_application_tags = bool<br>    record_client_address   = bool<br>    query_plans_per_minute  = number<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "query_plans_per_minute": 5,<br>  "query_string_length": 1024,<br>  "record_application_tags": false,<br>  "record_client_address": false<br>}</pre> | no |
| <a name="input_ipv4_enabled"></a> [ipv4\_enabled](#input\_ipv4\_enabled) | Add a public IP address to database instance. | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to be attached to all instances. | `map(string)` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Backup settings for primary instance. Will be automatically enabled if using MySQL with one or more replicas. | <pre>object({<br>    day          = string<br>    hour         = string<br>    update_track = string<br>  })</pre> | <pre>{<br>  "day": "6",<br>  "hour": "0",<br>  "update_track": "stable"<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name of primary instance. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | VPC self link where the instances will be deployed. Private Service Networking must be enabled and configured in this VPC. | `string` | n/a | yes |
| <a name="input_postgres_client_certificates"></a> [postgres\_client\_certificates](#input\_postgres\_client\_certificates) | Map of cert keys connect to the application(s) using public IP. | `list(string)` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Optional prefix used to generate instance names. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where this instances will be created. | `string` | n/a | yes |
| <a name="input_psc_subnet_name"></a> [psc\_subnet\_name](#input\_psc\_subnet\_name) | PSC subnet name where to place ip of cloud sql | `string` | n/a | yes |
| <a name="input_psc_vpc_name"></a> [psc\_vpc\_name](#input\_psc\_vpc\_name) | PSC vpc name where to place ip of cloud sql | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region of the primary instance. | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Map of NAME=> {REGION, KMS\_KEY} for additional read replicas. Set to null to disable replica creation. | <pre>map(object({<br>    region              = string<br>    encryption_key_name = string<br>    database_version    = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_root_password"></a> [root\_password](#input\_root\_password) | Root password of the Cloud SQL instance. Required for MS SQL Server. | `string` | `null` | no |
| <a name="input_ssl"></a> [ssl](#input\_ssl) | Setting to enable SSL, set config and certificates. | <pre>object({<br>    client_certificates = optional(list(string))<br>    # More details @ https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#ssl_mode<br>    mode = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | The machine type to use for the instances. | `string` | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | Map of users to create in the primary instance (and replicated to other replicas). For MySQL, anything after the first `@` (if present) will be used as the user's host. Set PASSWORD to null if you want to get an autogenerated password. The user types available are: 'BUILT\_IN', 'CLOUD\_IAM\_USER' or 'CLOUD\_IAM\_SERVICE\_ACCOUNT'. | <pre>map(object({<br>    password         = optional(string)<br>    type             = optional(string)<br>    access_to_db     = optional(list(string))<br>    override_special = optional(string, "-_.")<br>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_name"></a> [connection\_name](#output\_connection\_name) | Connection name of the primary instance. |
| <a name="output_connection_names"></a> [connection\_names](#output\_connection\_names) | Connection names of all instances. |
| <a name="output_id"></a> [id](#output\_id) | ID of the primary instance. |
| <a name="output_ids"></a> [ids](#output\_ids) | IDs of all instances. |
| <a name="output_instances"></a> [instances](#output\_instances) | Cloud SQL instance resources. |
| <a name="output_ip"></a> [ip](#output\_ip) | IP address of the primary instance. |
| <a name="output_ips"></a> [ips](#output\_ips) | IP addresses of all instances. |
| <a name="output_name"></a> [name](#output\_name) | Name of the primary instance. |
| <a name="output_names"></a> [names](#output\_names) | Names of all instances. |
| <a name="output_psc_service_attachment_link"></a> [psc\_service\_attachment\_link](#output\_psc\_service\_attachment\_link) | The URI that points to the service attachment of the instance. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | Self link of the primary instance. |
| <a name="output_self_links"></a> [self\_links](#output\_self\_links) | Self links of all instances. |
| <a name="output_user_passwords"></a> [user\_passwords](#output\_user\_passwords) | Map of containing the password of all users created through terraform. |
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 6.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.1.1 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 7.1.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_sql_database_instance.primary](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_sql_database_instance) | resource |
| [google-beta_google_sql_database_instance.replicas](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_sql_database_instance) | resource |
| [google-beta_google_sql_ssl_cert.client_certificates](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_sql_ssl_cert) | resource |
| [google_compute_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_secret_manager_secret.postgre_ssl_ca](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.postgre_ssl_crt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.postgre_ssl_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.postgre_ssl_ca](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_secret_manager_secret_version.postgre_ssl_crt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_secret_manager_secret_version.postgre_ssl_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_secret_manager_secret_version.secret_version_basic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_sql_database.databases](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_user.iam_users](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [google_sql_user.users](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [random_password.passwords](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) | resource |
| [google_compute_address.psc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_address) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_ip_ranges"></a> [allocated\_ip\_ranges](#input\_allocated\_ip\_ranges) | (Optional)The name of the allocated ip range for the private ip CloudSQL instance. For example: "google-managed-services-default". If set, the instance ip will be created in the allocated range. The range name must comply with RFC 1035. Specifically, the name must be 1-63 characters long and match the regular expression a-z?. | <pre>object({<br>    primary = optional(string)<br>    replica = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_authorized_networks"></a> [authorized\_networks](#input\_authorized\_networks) | Map of NAME=>CIDR\_RANGE to allow to connect to the database(s). | `map(string)` | `null` | no |
| <a name="input_availability_type"></a> [availability\_type](#input\_availability\_type) | Availability type for the primary replica. Either `ZONAL` or `REGIONAL`. | `string` | `"ZONAL"` | no |
| <a name="input_backup_configuration"></a> [backup\_configuration](#input\_backup\_configuration) | Backup settings for primary instance. Will be automatically enabled if using MySQL with one or more replicas. | <pre>object({<br>    enabled                        = bool<br>    binary_log_enabled             = bool<br>    start_time                     = string<br>    location                       = string<br>    point_in_time_recovery_enabled = bool<br>    log_retention_days             = number<br>    retention_count                = number<br>  })</pre> | <pre>{<br>  "binary_log_enabled": true,<br>  "enabled": true,<br>  "location": null,<br>  "log_retention_days": 7,<br>  "point_in_time_recovery_enabled": true,<br>  "retention_count": 7,<br>  "start_time": "23:00"<br>}</pre> | no |
| <a name="input_database_version"></a> [database\_version](#input\_database\_version) | (Required) The MySQL, PostgreSQL or SQL Server version to use. Supported values include MYSQL\_5\_6, MYSQL\_5\_7, MYSQL\_8\_0, MYSQL\_8\_4, POSTGRES\_9\_6,POSTGRES\_10, POSTGRES\_11, POSTGRES\_12, POSTGRES\_13, POSTGRES\_14, POSTGRES\_15, POSTGRES\_16, POSTGRES\_17, SQLSERVER\_2017\_STANDARD, SQLSERVER\_2017\_ENTERPRISE, SQLSERVER\_2017\_EXPRESS, SQLSERVER\_2017\_WEB. SQLSERVER\_2019\_STANDARD, SQLSERVER\_2019\_ENTERPRISE, SQLSERVER\_2019\_EXPRESS, SQLSERVER\_2019\_WEB | `string` | n/a | yes |
| <a name="input_databases"></a> [databases](#input\_databases) | Databases to create once the primary instance is created. | `list(string)` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Allow terraform to delete instances. | `bool` | `false` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size in GB. Set to null to enable autoresize. | `number` | `null` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | The type of data disk: `PD_SSD` or `PD_HDD`. | `string` | `"PD_SSD"` | no |
| <a name="input_enable_private_path_for_google_cloud_services"></a> [enable\_private\_path\_for\_google\_cloud\_services](#input\_enable\_private\_path\_for\_google\_cloud\_services) | (Optional) Whether Google Cloud services such as BigQuery are allowed to access data in this Cloud SQL instance over a private IP connection. SQLSERVER database type is not supported. Default: false | `bool` | `false` | no |
| <a name="input_encryption_key_name"></a> [encryption\_key\_name](#input\_encryption\_key\_name) | The full path to the encryption key used for the CMEK disk encryption of the primary instance. | `string` | `null` | no |
| <a name="input_flags"></a> [flags](#input\_flags) | Map FLAG\_NAME=>VALUE for database-specific tuning. | `map(string)` | `null` | no |
| <a name="input_iam_users"></a> [iam\_users](#input\_iam\_users) | List of IAM users to create with their types and emails | <pre>list(object({<br>    email = string<br>    type  = string<br>  }))</pre> | `[]` | no |
| <a name="input_insights_configuration"></a> [insights\_configuration](#input\_insights\_configuration) | Enable Query insights | <pre>object({<br>    enabled                 = bool<br>    query_string_length     = number<br>    record_application_tags = bool<br>    record_client_address   = bool<br>    query_plans_per_minute  = number<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "query_plans_per_minute": 5,<br>  "query_string_length": 1024,<br>  "record_application_tags": false,<br>  "record_client_address": false<br>}</pre> | no |
| <a name="input_ipv4_enabled"></a> [ipv4\_enabled](#input\_ipv4\_enabled) | Add a public IP address to database instance. | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to be attached to all instances. | `map(string)` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Backup settings for primary instance. Will be automatically enabled if using MySQL with one or more replicas. | <pre>object({<br>    day          = string<br>    hour         = string<br>    update_track = string<br>  })</pre> | <pre>{<br>  "day": "6",<br>  "hour": "0",<br>  "update_track": "stable"<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name of primary instance. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | VPC self link where the instances will be deployed. Private Service Networking must be enabled and configured in this VPC. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Optional prefix used to generate instance names. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where this instances will be created. | `string` | n/a | yes |
| <a name="input_psc_subnet_name"></a> [psc\_subnet\_name](#input\_psc\_subnet\_name) | PSC subnet name where to place ip of cloud sql | `string` | n/a | yes |
| <a name="input_psc_vpc_name"></a> [psc\_vpc\_name](#input\_psc\_vpc\_name) | PSC vpc name where to place ip of cloud sql | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region of the primary instance. | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Map of NAME=> {REGION, KMS\_KEY} for additional read replicas. Set to null to disable replica creation. | <pre>map(object({<br>    region              = string<br>    encryption_key_name = string<br>    database_version    = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_root_password"></a> [root\_password](#input\_root\_password) | Root password of the Cloud SQL instance. Required for MS SQL Server. | `string` | `null` | no |
| <a name="input_ssl"></a> [ssl](#input\_ssl) | Setting to enable SSL, set config and certificates. | <pre>object({<br>    client_certificates = optional(list(string))<br>    # More details @ https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#ssl_mode<br>    mode = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | The machine type to use for the instances. | `string` | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | Map of users to create in the primary instance (and replicated to other replicas). For MySQL, anything after the first `@` (if present) will be used as the user's host. Set PASSWORD to null if you want to get an autogenerated password. The user types available are: 'BUILT\_IN', 'CLOUD\_IAM\_USER' or 'CLOUD\_IAM\_SERVICE\_ACCOUNT'. | <pre>map(object({<br>    password         = optional(string)<br>    type             = optional(string)<br>    access_to_db     = optional(list(string))<br>    override_special = optional(string, "-_.")<br>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_name"></a> [connection\_name](#output\_connection\_name) | Connection name of the primary instance. |
| <a name="output_connection_names"></a> [connection\_names](#output\_connection\_names) | Connection names of all instances. |
| <a name="output_id"></a> [id](#output\_id) | ID of the primary instance. |
| <a name="output_ids"></a> [ids](#output\_ids) | IDs of all instances. |
| <a name="output_instances"></a> [instances](#output\_instances) | Cloud SQL instance resources. |
| <a name="output_ip"></a> [ip](#output\_ip) | IP address of the primary instance. |
| <a name="output_ips"></a> [ips](#output\_ips) | IP addresses of all instances. |
| <a name="output_name"></a> [name](#output\_name) | Name of the primary instance. |
| <a name="output_names"></a> [names](#output\_names) | Names of all instances. |
| <a name="output_psc_service_attachment_link"></a> [psc\_service\_attachment\_link](#output\_psc\_service\_attachment\_link) | The URI that points to the service attachment of the instance. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | Self link of the primary instance. |
| <a name="output_self_links"></a> [self\_links](#output\_self\_links) | Self links of all instances. |
| <a name="output_user_passwords"></a> [user\_passwords](#output\_user\_passwords) | Map of containing the password of all users created through terraform. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

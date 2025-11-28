<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

No requirements.
## Usage
Basic usage of this module is as follows:
```hcl
module "example" {
	 source  = "<module-path>"

	 # Required variables
	 location  =
	 project  =
	 region  =
	 vpc_name  =

	 # Optional variables
	 cloud_nat  = []
	 default_rules_config  = {}
	 egress_rules  = {}
	 external_addresses  = {}
	 ingress_rules  = {}
	 psa_config  = null
	 shared_vpc_host  = true
	 shared_vpc_service_projects  = []
	 subnet_iam  = {}
	 subnets  = []
	 subnets_psc  = []

```
## Resources

No resources.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_nat"></a> [cloud\_nat](#input\_cloud\_nat) | Cloud Nat's to create for networks | <pre>list(object({<br>    name                                = string<br>    region                              = string<br>    addresses                           = optional(list(string))<br>    external_address_name               = string<br>    enable_endpoint_independent_mapping = optional(bool)<br>    config_min_ports_per_vm             = optional(number, 64)<br>    config_port_allocation = optional(object({<br>      enable_endpoint_independent_mapping = optional(bool, true)<br>      enable_dynamic_port_allocation      = optional(bool, false)<br>      min_ports_per_vm                    = optional(number, 64)<br>      max_ports_per_vm                    = optional(number, 65536)<br>      })<br>    )<br>    config_source_subnets = optional(string, "ALL_SUBNETWORKS_ALL_IP_RANGES")<br>    config_timeouts = optional(object({<br>      icmp            = number<br>      tcp_established = number<br>      tcp_transitory  = number<br>      udp             = number<br>      }), {<br>      icmp            = 30<br>      tcp_established = 1200<br>      tcp_transitory  = 30<br>      udp             = 30<br>    })<br>    logging_filter = optional(string)<br>    router_asn     = optional(number)<br>    router_create  = optional(bool)<br><br>    router_name    = optional(string)<br>    router_network = optional(string)<br>    subnetworks = optional(list(object({<br>      self_link            = string,<br>      config_source_ranges = list(string)<br>      secondary_ranges     = list(string)<br>    })))<br><br>  }))</pre> | `[]` | no |
| <a name="input_default_rules_config"></a> [default\_rules\_config](#input\_default\_rules\_config) | Optionally created convenience rules. Set the 'disabled' attribute to true, or individual rule attributes to empty lists to disable. | <pre>object({<br>    admin_ranges = optional(list(string))<br>    disabled     = optional(bool, false)<br>    http_ranges = optional(list(string), [<br>      "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]<br>    )<br>    http_tags = optional(list(string), ["http-server"])<br>    https_ranges = optional(list(string), [<br>      "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]<br>    )<br>    https_tags = optional(list(string), ["https-server"])<br>    ssh_ranges = optional(list(string), ["35.235.240.0/20"])<br>    ssh_tags   = optional(list(string), ["ssh"])<br>  })</pre> | `{}` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | List of egress rule definitions, default to deny action. Null destination ranges will be replaced with 0/0. | <pre>map(object({<br>    deny               = optional(bool, true)<br>    description        = optional(string)<br>    destination_ranges = optional(list(string))<br>    disabled           = optional(bool, false)<br>    enable_logging = optional(object({<br>      include_metadata = optional(bool)<br>    }))<br>    priority             = optional(number, 1000)<br>    targets              = optional(list(string))<br>    use_service_accounts = optional(bool, false)<br>    rules = optional(list(object({<br>      protocol = string<br>      ports    = optional(list(string))<br>    })), [{ protocol = "all" }])<br>  }))</pre> | `{}` | no |
| <a name="input_external_addresses"></a> [external\_addresses](#input\_external\_addresses) | Map of external address regions, keyed by name. | `map(string)` | `{}` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | List of ingress rule definitions, default to allow action. Null source ranges will be replaced with 0/0. | <pre>map(object({<br>    deny        = optional(bool, false)<br>    description = optional(string)<br>    disabled    = optional(bool, false)<br>    enable_logging = optional(object({<br>      include_metadata = optional(bool)<br>    }))<br>    priority             = optional(number, 1000)<br>    source_ranges        = optional(list(string))<br>    sources              = optional(list(string))<br>    targets              = optional(list(string))<br>    use_service_accounts = optional(bool, false)<br>    rules = optional(list(object({<br>      protocol = string<br>      ports    = optional(list(string))<br>    })), [{ protocol = "all" }])<br>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The location (region or zone) to host the cluster in | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project ID to host the vpc in | `string` | n/a | yes |
| <a name="input_psa_config"></a> [psa\_config](#input\_psa\_config) | The Private Service Access configuration for Service Networking. | <pre>object({<br>    ranges        = optional(map(string))<br>    export_routes = optional(bool, false)<br>    import_routes = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to host the cluster in | `string` | n/a | yes |
| <a name="input_shared_vpc_host"></a> [shared\_vpc\_host](#input\_shared\_vpc\_host) | Enable shared VPC for this project. | `bool` | `true` | no |
| <a name="input_shared_vpc_service_projects"></a> [shared\_vpc\_service\_projects](#input\_shared\_vpc\_service\_projects) | Shared VPC service projects to register with this host. | `list(string)` | `[]` | no |
| <a name="input_subnet_iam"></a> [subnet\_iam](#input\_subnet\_iam) | Subnet IAM bindings in {REGION/NAME => {ROLE => [MEMBERS]} format. | `map(map(list(string)))` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnet configuration. | <pre>list(object({<br>    name                  = string<br>    ip_cidr_range         = string<br>    region                = string<br>    description           = optional(string)<br>    enable_private_access = optional(bool, true)<br>    flow_logs_config = optional(object({<br>      aggregation_interval = optional(string)<br>      filter_expression    = optional(string)<br>      flow_sampling        = optional(number)<br>      metadata             = optional(string)<br>      # only if metadata == "CUSTOM_METADATA"<br>      metadata_fields = optional(list(string))<br>    }))<br>    ipv6 = optional(object({<br>      access_type = optional(string, "INTERNAL")<br>      # this field is marked for internal use in the API documentation<br>      # enable_private_access = optional(string)<br>    }))<br>    secondary_ip_ranges = optional(map(string))<br><br>    iam = optional(map(list(string)), {})<br>    iam_bindings = optional(map(object({<br>      role    = string<br>      members = list(string)<br>      condition = optional(object({<br>        expression  = string<br>        title       = string<br>        description = optional(string)<br>      }))<br>    })), {})<br>    iam_bindings_additive = optional(map(object({<br>      member = string<br>      role   = string<br>      condition = optional(object({<br>        expression  = string<br>        title       = string<br>        description = optional(string)<br>      }))<br>    })), {})<br>  }))</pre> | `[]` | no |
| <a name="input_subnets_psc"></a> [subnets\_psc](#input\_subnets\_psc) | List of subnets for Private Service Connect service producers. | <pre>list(object({<br>    name          = string<br>    ip_cidr_range = string<br>    region        = string<br>    description   = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of shared VPC to create | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_router_name"></a> [cloud\_router\_name](#output\_cloud\_router\_name) | Name of create Cloud router |
| <a name="output_subnet_secondary_ranges"></a> [subnet\_secondary\_ranges](#output\_subnet\_secondary\_ranges) | Map of subnet secondary ranges keyed by name. |
| <a name="output_subnets_psc"></a> [subnets\_psc](#output\_subnets\_psc) | Private Service Connect subnet resources. |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the VPC being created. |
| <a name="output_vpc_project"></a> [vpc\_project](#output\_vpc\_project) | Project where vpc is deployed |
| <a name="output_vpc_self_link"></a> [vpc\_self\_link](#output\_vpc\_self\_link) | The URI of the VPC being created. |
| <a name="output_vpc_subnet_links"></a> [vpc\_subnet\_links](#output\_vpc\_subnet\_links) | Map of subnet self links keyed by name. |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.49.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_addresses"></a> [addresses](#module\_addresses) | github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-address | v40.0.0 |
| <a name="module_firewall"></a> [firewall](#module\_firewall) | github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-vpc-firewall | v40.0.0 |
| <a name="module_nat"></a> [nat](#module\_nat) | github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-cloudnat | v40.0.0 |
| <a name="module_vpc_host"></a> [vpc\_host](#module\_vpc\_host) | github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-vpc | v40.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_nat"></a> [cloud\_nat](#input\_cloud\_nat) | Cloud Nat's to create for networks | <pre>list(object({<br>    name                                = string<br>    region                              = string<br>    addresses                           = optional(list(string))<br>    external_address_name               = string<br>    enable_endpoint_independent_mapping = optional(bool)<br>    config_min_ports_per_vm             = optional(number, 64)<br>    config_port_allocation = optional(object({<br>      enable_endpoint_independent_mapping = optional(bool, true)<br>      enable_dynamic_port_allocation      = optional(bool, false)<br>      min_ports_per_vm                    = optional(number, 64)<br>      max_ports_per_vm                    = optional(number, 65536)<br>      })<br>    )<br>    config_source_subnets = optional(object({<br>      all                 = optional(bool, true)<br>      primary_ranges_only = optional(bool)<br>      subnetworks = optional(list(object({<br>        self_link        = string<br>        all_ranges       = optional(bool, true)<br>        primary_range    = optional(bool, false)<br>        secondary_ranges = optional(list(string))<br>      })), [])<br>    }))<br><br>    config_timeouts = optional(object({<br>      icmp            = number<br>      tcp_established = number<br>      tcp_transitory  = number<br>      udp             = number<br>      }), {<br>      icmp            = 30<br>      tcp_established = 1200<br>      tcp_transitory  = 30<br>      udp             = 30<br>    })<br>    logging_filter = optional(string)<br>    router_asn     = optional(number)<br>    router_create  = optional(bool)<br><br>    router_name    = optional(string)<br>    router_network = optional(string)<br>    subnetworks = optional(list(object({<br>      self_link            = string,<br>      config_source_ranges = list(string)<br>      secondary_ranges     = list(string)<br>    })))<br><br>  }))</pre> | `[]` | no |
| <a name="input_create_googleapis_routes"></a> [create\_googleapis\_routes](#input\_create\_googleapis\_routes) | Toggle creation of googleapis private/restricted routes. Disabled when vpc creation is turned off, or when set to null. | <pre>object({<br>    directpath   = optional(bool, false)<br>    directpath-6 = optional(bool, false)<br>    private      = optional(bool, true)<br>    private-6    = optional(bool, false)<br>    restricted   = optional(bool, true)<br>    restricted-6 = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_default_rules_config"></a> [default\_rules\_config](#input\_default\_rules\_config) | Optionally created convenience rules. Set the 'disabled' attribute to true, or individual rule attributes to empty lists to disable. | <pre>object({<br>    admin_ranges = optional(list(string))<br>    disabled     = optional(bool, false)<br>    http_ranges = optional(list(string), [<br>      "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]<br>    )<br>    http_tags = optional(list(string), ["http-server"])<br>    https_ranges = optional(list(string), [<br>      "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]<br>    )<br>    https_tags = optional(list(string), ["https-server"])<br>    ssh_ranges = optional(list(string), ["35.235.240.0/20"])<br>    ssh_tags   = optional(list(string), ["ssh"])<br>  })</pre> | `{}` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | List of egress rule definitions, default to deny action. Null destination ranges will be replaced with 0/0. | <pre>map(object({<br>    deny               = optional(bool, true)<br>    description        = optional(string)<br>    destination_ranges = optional(list(string))<br>    disabled           = optional(bool, false)<br>    enable_logging = optional(object({<br>      include_metadata = optional(bool)<br>    }))<br>    priority             = optional(number, 1000)<br>    targets              = optional(list(string))<br>    use_service_accounts = optional(bool, false)<br>    rules = optional(list(object({<br>      protocol = string<br>      ports    = optional(list(string))<br>    })), [{ protocol = "all" }])<br>  }))</pre> | `{}` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | List of ingress rule definitions, default to allow action. Null source ranges will be replaced with 0/0. | <pre>map(object({<br>    deny        = optional(bool, false)<br>    description = optional(string)<br>    disabled    = optional(bool, false)<br>    enable_logging = optional(object({<br>      include_metadata = optional(bool)<br>    }))<br>    priority             = optional(number, 1000)<br>    source_ranges        = optional(list(string))<br>    destination_ranges   = optional(list(string))<br>    sources              = optional(list(string))<br>    targets              = optional(list(string))<br>    use_service_accounts = optional(bool, false)<br>    rules = optional(list(object({<br>      protocol = string<br>      ports    = optional(list(string))<br>    })), [{ protocol = "all" }])<br>  }))</pre> | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | The project ID to host the vpc in | `string` | n/a | yes |
| <a name="input_psa_configs"></a> [psa\_configs](#input\_psa\_configs) | The Private Service Access configuration. | <pre>list(object({<br>    deletion_policy  = optional(string, null)<br>    ranges           = map(string)<br>    export_routes    = optional(bool, false)<br>    import_routes    = optional(bool, false)<br>    peered_domains   = optional(list(string), [])<br>    range_prefix     = optional(string)<br>    service_producer = optional(string, "servicenetworking.googleapis.com")<br>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to host the cluster in | `string` | n/a | yes |
| <a name="input_shared_vpc_host"></a> [shared\_vpc\_host](#input\_shared\_vpc\_host) | Enable shared VPC for this project. | `bool` | `true` | no |
| <a name="input_shared_vpc_service_projects"></a> [shared\_vpc\_service\_projects](#input\_shared\_vpc\_service\_projects) | Shared VPC service projects to register with this host. | `list(string)` | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnet configuration. | <pre>list(object({<br>    name                  = string<br>    ip_cidr_range         = string<br>    region                = string<br>    description           = optional(string)<br>    enable_private_access = optional(bool, true)<br>    flow_logs_config = optional(object({<br>      aggregation_interval = optional(string)<br>      filter_expression    = optional(string)<br>      flow_sampling        = optional(number)<br>      metadata             = optional(string)<br>      # only if metadata == "CUSTOM_METADATA"<br>      metadata_fields = optional(list(string))<br>    }))<br>    ipv6 = optional(object({<br>      access_type = optional(string, "INTERNAL")<br>      # this field is marked for internal use in the API documentation<br>      # enable_private_access = optional(string)<br>    }))<br>    secondary_ip_ranges = optional(map(string))<br><br>    iam = optional(map(list(string)), {})<br>    iam_bindings = optional(map(object({<br>      role    = string<br>      members = list(string)<br>      condition = optional(object({<br>        expression  = string<br>        title       = string<br>        description = optional(string)<br>      }))<br>    })), {})<br>    iam_bindings_additive = optional(map(object({<br>      member = string<br>      role   = string<br>      condition = optional(object({<br>        expression  = string<br>        title       = string<br>        description = optional(string)<br>      }))<br>    })), {})<br>  }))</pre> | `[]` | no |
| <a name="input_subnets_proxy_only"></a> [subnets\_proxy\_only](#input\_subnets\_proxy\_only) | List of proxy-only subnets for Regional HTTPS or Internal HTTPS load balancers. Note: Only one proxy-only subnet for each VPC network in each region can be active. | <pre>list(object({<br>    name          = string<br>    ip_cidr_range = string<br>    region        = string<br>    description   = optional(string)<br>    active        = optional(bool, true)<br>    global        = optional(bool, false)<br><br>    iam = optional(map(list(string)), {})<br>    iam_bindings = optional(map(object({<br>      role    = string<br>      members = list(string)<br>      condition = optional(object({<br>        expression  = string<br>        title       = string<br>        description = optional(string)<br>      }))<br>    })), {})<br>    iam_bindings_additive = optional(map(object({<br>      member = string<br>      role   = string<br>      condition = optional(object({<br>        expression  = string<br>        title       = string<br>        description = optional(string)<br>      }))<br>    })), {})<br>  }))</pre> | `[]` | no |
| <a name="input_subnets_psc"></a> [subnets\_psc](#input\_subnets\_psc) | List of subnets for Private Service Connect service producers. | <pre>list(object({<br>    name          = string<br>    ip_cidr_range = string<br>    region        = string<br>    description   = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of shared VPC to create | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_router_name"></a> [cloud\_router\_name](#output\_cloud\_router\_name) | Name of create Cloud router |
| <a name="output_subnet_secondary_ranges"></a> [subnet\_secondary\_ranges](#output\_subnet\_secondary\_ranges) | Map of subnet secondary ranges keyed by name. |
| <a name="output_subnets_proxy_only"></a> [subnets\_proxy\_only](#output\_subnets\_proxy\_only) | L7 ILB or L7 Regional LB subnet resources. |
| <a name="output_subnets_psc"></a> [subnets\_psc](#output\_subnets\_psc) | Private Service Connect subnet resources. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The name of the VPC being created. |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the VPC being created. |
| <a name="output_vpc_project"></a> [vpc\_project](#output\_vpc\_project) | Project where vpc is deployed |
| <a name="output_vpc_self_link"></a> [vpc\_self\_link](#output\_vpc\_self\_link) | The URI of the VPC being created. |
| <a name="output_vpc_subnet_links"></a> [vpc\_subnet\_links](#output\_vpc\_subnet\_links) | Map of subnet self links keyed by name. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

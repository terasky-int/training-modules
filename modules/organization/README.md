# organization

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.4 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.33.0, < 7.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 6.33.0, < 7.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.49.3 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 6.49.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_essential_contacts_contact.contact](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_essential_contacts_contact) | resource |
| [google-beta_google_org_policy_custom_constraint.constraint](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_org_policy_custom_constraint) | resource |
| [google_bigquery_dataset_iam_member.bq_sinks_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_compute_firewall_policy_association.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall_policy_association) | resource |
| [google_iam_deny_policy.deny](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_deny_policy) | resource |
| [google_logging_organization_exclusion.logging_exclusion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_organization_exclusion) | resource |
| [google_logging_organization_settings.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_organization_settings) | resource |
| [google_logging_organization_sink.sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_organization_sink) | resource |
| [google_org_policy_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/org_policy_policy) | resource |
| [google_organization_iam_audit_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_audit_config) | resource |
| [google_organization_iam_binding.authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_binding) | resource |
| [google_organization_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_binding) | resource |
| [google_organization_iam_custom_role.dynamic_custom_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_custom_role.roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_member.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.dynamic_custom_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_member.bucket_sinks_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.project_sinks_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_topic_iam_member.pubsub_sinks_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_storage_bucket_iam_member.storage_sinks_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_tags_tag_binding.binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_binding) | resource |
| [google_tags_tag_key.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_key) | resource |
| [google_tags_tag_key_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_key_iam_binding) | resource |
| [google_tags_tag_key_iam_binding.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_key_iam_binding) | resource |
| [google_tags_tag_key_iam_member.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_key_iam_member) | resource |
| [google_tags_tag_value.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_value) | resource |
| [google_tags_tag_value_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_value_iam_binding) | resource |
| [google_tags_tag_value_iam_binding.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_value_iam_binding) | resource |
| [google_tags_tag_value_iam_member.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_value_iam_member) | resource |
| [google_iam_role.roleinfo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_contacts"></a> [contacts](#input\_contacts) | List of essential contacts for this resource. Must be in the form EMAIL -> [NOTIFICATION\_TYPES]. Valid notification types are ALL, SUSPENSION, SECURITY, TECHNICAL, BILLING, LEGAL, PRODUCT\_UPDATES. | `map(list(string))` | `{}` | no |
| <a name="input_custom_roles"></a> [custom\_roles](#input\_custom\_roles) | Map of role name => list of permissions to create in this project. | `map(list(string))` | `{}` | no |
| <a name="input_deny_policies"></a> [deny\_policies](#input\_deny\_policies) | Map of deny policies to create. Key = policy\_id or name suffix. | <pre>map(object({<br>    parent       = string<br>    display_name = optional(string)<br>    name         = string<br>    rules = list(object({<br>      denied_principals     = optional(list(string))<br>      exception_principals  = optional(list(string))<br>      denied_permissions    = optional(list(string))<br>      exception_permissions = optional(list(string))<br>      denial_condition = optional(object({<br>        title       = optional(string)<br>        description = optional(string)<br>        expression  = string<br>      }))<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_dynamic_custom_roles"></a> [dynamic\_custom\_roles](#input\_dynamic\_custom\_roles) | Object of dynamic custom role | <pre>map(object({<br>    parents_roles       = list(string)<br>    exclude_permissions = list(string)<br>    role_title          = string<br>    role_description    = string<br>    attached_to         = optional(list(string))<br>  }))</pre> | `{}` | no |
| <a name="input_factories_config"></a> [factories\_config](#input\_factories\_config) | Paths to data files and folders that enable factory functionality. | <pre>object({<br>    custom_roles                  = optional(string)<br>    org_policies                  = optional(string)<br>    org_policy_custom_constraints = optional(string)<br>    context = optional(object({<br>      org_policies = optional(map(map(string)), {})<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_firewall_policy"></a> [firewall\_policy](#input\_firewall\_policy) | Hierarchical firewall policies to associate to the organization. | <pre>object({<br>    name   = string<br>    policy = string<br>  })</pre> | `null` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | IAM bindings, in {ROLE => [MEMBERS]} format. | `map(list(string))` | `{}` | no |
| <a name="input_iam_bindings"></a> [iam\_bindings](#input\_iam\_bindings) | Authoritative IAM bindings in {KEY => {role = ROLE, members = [], condition = {}}}. Keys are arbitrary. | <pre>map(object({<br>    members = list(string)<br>    role    = string<br>    condition = optional(object({<br>      expression  = string<br>      title       = string<br>      description = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_iam_bindings_additive"></a> [iam\_bindings\_additive](#input\_iam\_bindings\_additive) | Individual additive IAM bindings. Keys are arbitrary. | <pre>map(object({<br>    member = string<br>    role   = string<br>    condition = optional(object({<br>      expression  = string<br>      title       = string<br>      description = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_iam_by_principals"></a> [iam\_by\_principals](#input\_iam\_by\_principals) | Authoritative IAM binding in {PRINCIPAL => [ROLES]} format. Principals need to be statically defined to avoid errors. Merged internally with the `iam` variable. | `map(list(string))` | `{}` | no |
| <a name="input_iam_by_principals_additive"></a> [iam\_by\_principals\_additive](#input\_iam\_by\_principals\_additive) | Additive IAM binding in {PRINCIPAL => [ROLES]} format. Principals need to be statically defined to avoid errors. Merged internally with the `iam_bindings_additive` variable. | `map(list(string))` | `{}` | no |
| <a name="input_logging_data_access"></a> [logging\_data\_access](#input\_logging\_data\_access) | Control activation of data access logs. The special 'allServices' key denotes configuration for all services. | <pre>map(object({<br>    ADMIN_READ = optional(object({ exempted_members = optional(list(string)) })),<br>    DATA_READ  = optional(object({ exempted_members = optional(list(string)) })),<br>    DATA_WRITE = optional(object({ exempted_members = optional(list(string)) }))<br>  }))</pre> | `{}` | no |
| <a name="input_logging_exclusions"></a> [logging\_exclusions](#input\_logging\_exclusions) | Logging exclusions for this organization in the form {NAME -> FILTER}. | `map(string)` | `{}` | no |
| <a name="input_logging_settings"></a> [logging\_settings](#input\_logging\_settings) | Default settings for logging resources. | <pre>object({<br>    # TODO: add support for CMEK<br>    disable_default_sink = optional(bool)<br>    storage_location     = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_logging_sinks"></a> [logging\_sinks](#input\_logging\_sinks) | Logging sinks to create for the organization. | <pre>map(object({<br>    bq_partitioned_table = optional(bool, false)<br>    description          = optional(string)<br>    destination          = string<br>    disabled             = optional(bool, false)<br>    exclusions           = optional(map(string), {})<br>    filter               = optional(string)<br>    iam                  = optional(bool, true)<br>    include_children     = optional(bool, true)<br>    intercept_children   = optional(bool, false)<br>    type                 = string<br>  }))</pre> | `{}` | no |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | Network tags by key name. If `id` is provided, key creation is skipped. The `iam` attribute behaves like the similarly named one at module level. | <pre>map(object({<br>    description = optional(string, "Managed by the Terraform organization module.")<br>    iam         = optional(map(list(string)), {})<br>    iam_bindings = optional(map(object({<br>      members = list(string)<br>      role    = string<br>      condition = optional(object({<br>        expression  = string<br>        title       = string<br>        description = optional(string)<br>      }))<br>    })), {})<br>    iam_bindings_additive = optional(map(object({<br>      member = string<br>      role   = string<br>      condition = optional(object({<br>        expression  = string<br>        title       = string<br>        description = optional(string)<br>      }))<br>    })), {})<br>    id      = optional(string)<br>    network = string # project_id/vpc_name<br>    values = optional(map(object({<br>      description = optional(string, "Managed by the Terraform organization module.")<br>      iam         = optional(map(list(string)), {})<br>      iam_bindings = optional(map(object({<br>        members = list(string)<br>        role    = string<br>        condition = optional(object({<br>          expression  = string<br>          title       = string<br>          description = optional(string)<br>        }))<br>      })), {})<br>      iam_bindings_additive = optional(map(object({<br>        member = string<br>        role   = string<br>        condition = optional(object({<br>          expression  = string<br>          title       = string<br>          description = optional(string)<br>        }))<br>      })), {})<br>    })), {})<br>  }))</pre> | `{}` | no |
| <a name="input_org_policies"></a> [org\_policies](#input\_org\_policies) | Organization policies applied to this organization keyed by policy name. | <pre>map(object({<br>    inherit_from_parent = optional(bool) # for list policies only.<br>    reset               = optional(bool)<br>    rules = optional(list(object({<br>      allow = optional(object({<br>        all    = optional(bool)<br>        values = optional(list(string))<br>      }))<br>      deny = optional(object({<br>        all    = optional(bool)<br>        values = optional(list(string))<br>      }))<br>      enforce = optional(bool) # for boolean policies only.<br>      condition = optional(object({<br>        description = optional(string)<br>        expression  = optional(string)<br>        location    = optional(string)<br>        title       = optional(string)<br>      }), {})<br>      parameters = optional(string)<br>    })), [])<br>  }))</pre> | `{}` | no |
| <a name="input_org_policy_custom_constraints"></a> [org\_policy\_custom\_constraints](#input\_org\_policy\_custom\_constraints) | Organization policy custom constraints keyed by constraint name. | <pre>map(object({<br>    display_name   = optional(string)<br>    description    = optional(string)<br>    action_type    = string<br>    condition      = string<br>    method_types   = list(string)<br>    resource_types = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | Organization id in organizations/nnnnnn format. | `string` | n/a | yes |
| <a name="input_tag_bindings"></a> [tag\_bindings](#input\_tag\_bindings) | Tag bindings for this organization, in key => tag value id format. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags by key name. If `id` is provided, key or value creation is skipped. The `iam` attribute behaves like the similarly named one at module level. | <pre>map(object({<br>    description = optional(string, "Managed by the Terraform organization module.")<br>    iam         = optional(map(list(string)), {})<br>    iam_bindings = optional(map(object({<br>      members = list(string)<br>      role    = string<br>      condition = optional(object({<br>        expression  = string<br>        title       = string<br>        description = optional(string)<br>      }))<br>    })), {})<br>    iam_bindings_additive = optional(map(object({<br>      member = string<br>      role   = string<br>      condition = optional(object({<br>        expression  = string<br>        title       = string<br>        description = optional(string)<br>      }))<br>    })), {})<br>    id = optional(string)<br>    values = optional(map(object({<br>      description = optional(string, "Managed by the Terraform organization module.")<br>      iam         = optional(map(list(string)), {})<br>      iam_bindings = optional(map(object({<br>        members = list(string)<br>        role    = string<br>        condition = optional(object({<br>          expression  = string<br>          title       = string<br>          description = optional(string)<br>        }))<br>      })), {})<br>      iam_bindings_additive = optional(map(object({<br>        member = string<br>        role   = string<br>        condition = optional(object({<br>          expression  = string<br>          title       = string<br>          description = optional(string)<br>        }))<br>      })), {})<br>      id = optional(string)<br>    })), {})<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_constraint_ids"></a> [custom\_constraint\_ids](#output\_custom\_constraint\_ids) | Map of CUSTOM\_CONSTRAINTS => ID in the organization. |
| <a name="output_custom_role_id"></a> [custom\_role\_id](#output\_custom\_role\_id) | Map of custom role IDs created in the organization. |
| <a name="output_custom_roles"></a> [custom\_roles](#output\_custom\_roles) | Map of custom roles resources created in the organization. |
| <a name="output_id"></a> [id](#output\_id) | Fully qualified organization id. |
| <a name="output_network_tag_keys"></a> [network\_tag\_keys](#output\_network\_tag\_keys) | Tag key resources. |
| <a name="output_network_tag_values"></a> [network\_tag\_values](#output\_network\_tag\_values) | Tag value resources. |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | Organization id dependent on module resources. |
| <a name="output_sink_writer_identities"></a> [sink\_writer\_identities](#output\_sink\_writer\_identities) | Writer identities created for each sink. |
| <a name="output_tag_keys"></a> [tag\_keys](#output\_tag\_keys) | Tag key resources. |
| <a name="output_tag_values"></a> [tag\_values](#output\_tag\_values) | Tag value resources. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

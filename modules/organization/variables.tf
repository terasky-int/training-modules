variable "contacts" {
  description = "List of essential contacts for this resource. Must be in the form EMAIL -> [NOTIFICATION_TYPES]. Valid notification types are ALL, SUSPENSION, SECURITY, TECHNICAL, BILLING, LEGAL, PRODUCT_UPDATES."
  type        = map(list(string))
  default     = {}
  nullable    = false
}

variable "custom_roles" {
  description = "Map of role name => list of permissions to create in this project."
  type        = map(list(string))
  default     = {}
  nullable    = false
}

variable "factories_config" {
  description = "Paths to data files and folders that enable factory functionality."
  type = object({
    custom_roles                  = optional(string)
    org_policies                  = optional(string)
    org_policy_custom_constraints = optional(string)
    context = optional(object({
      org_policies = optional(map(map(string)), {})
    }), {})
  })
  nullable = false
  default  = {}
}

variable "firewall_policy" {
  description = "Hierarchical firewall policies to associate to the organization."
  type = object({
    name   = string
    policy = string
  })
  default = null
}

variable "org_policies" {
  description = "Organization policies applied to this organization keyed by policy name."
  type = map(object({
    inherit_from_parent = optional(bool) # for list policies only.
    reset               = optional(bool)
    rules = optional(list(object({
      allow = optional(object({
        all    = optional(bool)
        values = optional(list(string))
      }))
      deny = optional(object({
        all    = optional(bool)
        values = optional(list(string))
      }))
      enforce = optional(bool) # for boolean policies only.
      condition = optional(object({
        description = optional(string)
        expression  = optional(string)
        location    = optional(string)
        title       = optional(string)
      }), {})
      parameters = optional(string)
    })), [])
  }))
  default  = {}
  nullable = false
}

variable "org_policy_custom_constraints" {
  description = "Organization policy custom constraints keyed by constraint name."
  type = map(object({
    display_name   = optional(string)
    description    = optional(string)
    action_type    = string
    condition      = string
    method_types   = list(string)
    resource_types = list(string)
  }))
  default  = {}
  nullable = false
}

variable "organization_id" {
  description = "Organization id in organizations/nnnnnn format."
  type        = string
  validation {
    condition     = can(regex("^organizations/[0-9]+", var.organization_id))
    error_message = "The organization_id must in the form organizations/nnn."
  }
}

variable "iam" {
  description = "IAM bindings, in {ROLE => [MEMBERS]} format."
  type        = map(list(string))
  default     = {}
  nullable    = false
}

variable "iam_bindings" {
  description = "Authoritative IAM bindings in {KEY => {role = ROLE, members = [], condition = {}}}. Keys are arbitrary."
  type = map(object({
    members = list(string)
    role    = string
    condition = optional(object({
      expression  = string
      title       = string
      description = optional(string)
    }))
  }))
  nullable = false
  default  = {}
}

variable "iam_bindings_additive" {
  description = "Individual additive IAM bindings. Keys are arbitrary."
  type = map(object({
    member = string
    role   = string
    condition = optional(object({
      expression  = string
      title       = string
      description = optional(string)
    }))
  }))
  nullable = false
  default  = {}
}

variable "iam_by_principals_additive" {
  description = "Additive IAM binding in {PRINCIPAL => [ROLES]} format. Principals need to be statically defined to avoid errors. Merged internally with the `iam_bindings_additive` variable."
  type        = map(list(string))
  default     = {}
  nullable    = false
}

variable "iam_by_principals" {
  description = "Authoritative IAM binding in {PRINCIPAL => [ROLES]} format. Principals need to be statically defined to avoid errors. Merged internally with the `iam` variable."
  type        = map(list(string))
  default     = {}
  nullable    = false
}

variable "logging_data_access" {
  description = "Control activation of data access logs. The special 'allServices' key denotes configuration for all services."
  type = map(object({
    ADMIN_READ = optional(object({ exempted_members = optional(list(string)) })),
    DATA_READ  = optional(object({ exempted_members = optional(list(string)) })),
    DATA_WRITE = optional(object({ exempted_members = optional(list(string)) }))
  }))
  default  = {}
  nullable = false
}

variable "logging_exclusions" {
  description = "Logging exclusions for this organization in the form {NAME -> FILTER}."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "logging_settings" {
  description = "Default settings for logging resources."
  type = object({
    # TODO: add support for CMEK
    disable_default_sink = optional(bool)
    storage_location     = optional(string)
  })
  default = null
}

variable "logging_sinks" {
  description = "Logging sinks to create for the organization."
  type = map(object({
    bq_partitioned_table = optional(bool, false)
    description          = optional(string)
    destination          = string
    disabled             = optional(bool, false)
    exclusions           = optional(map(string), {})
    filter               = optional(string)
    iam                  = optional(bool, true)
    include_children     = optional(bool, true)
    intercept_children   = optional(bool, false)
    type                 = string
  }))
  default  = {}
  nullable = false
  validation {
    condition = alltrue([
      for k, v in var.logging_sinks :
      !v.intercept_children || (v.include_children && v.type == "project")
    ])
    error_message = "'type' must be set to 'project' if 'intercept_children' is 'true'."
  }
  validation {
    condition = alltrue([
      for k, v in var.logging_sinks :
      contains(["bigquery", "logging", "project", "pubsub", "storage"], v.type)
    ])
    error_message = "Type must be one of 'bigquery', 'logging', 'project', 'pubsub', 'storage'."
  }
  validation {
    condition = alltrue([
      for k, v in var.logging_sinks :
      v.bq_partitioned_table != true || v.type == "bigquery"
    ])
    error_message = "Can only set bq_partitioned_table when type is `bigquery`."
  }
}

variable "network_tags" {
  description = "Network tags by key name. If `id` is provided, key creation is skipped. The `iam` attribute behaves like the similarly named one at module level."
  type = map(object({
    description = optional(string, "Managed by the Terraform organization module.")
    iam         = optional(map(list(string)), {})
    iam_bindings = optional(map(object({
      members = list(string)
      role    = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    iam_bindings_additive = optional(map(object({
      member = string
      role   = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    id      = optional(string)
    network = string # project_id/vpc_name
    values = optional(map(object({
      description = optional(string, "Managed by the Terraform organization module.")
      iam         = optional(map(list(string)), {})
      iam_bindings = optional(map(object({
        members = list(string)
        role    = string
        condition = optional(object({
          expression  = string
          title       = string
          description = optional(string)
        }))
      })), {})
      iam_bindings_additive = optional(map(object({
        member = string
        role   = string
        condition = optional(object({
          expression  = string
          title       = string
          description = optional(string)
        }))
      })), {})
    })), {})
  }))
  nullable = false
  default  = {}
  validation {
    condition = (
      alltrue([
        for k, v in var.network_tags : v != null
      ]) &&
      # all values are non-null
      alltrue(flatten([
        for k, v in var.network_tags : [for k2, v2 in v.values : v2 != null]
      ]))
    )
    error_message = "Use an empty map instead of null as value."
  }
}

variable "tag_bindings" {
  description = "Tag bindings for this organization, in key => tag value id format."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "tags" {
  description = "Tags by key name. If `id` is provided, key or value creation is skipped. The `iam` attribute behaves like the similarly named one at module level."
  type = map(object({
    description = optional(string, "Managed by the Terraform organization module.")
    iam         = optional(map(list(string)), {})
    iam_bindings = optional(map(object({
      members = list(string)
      role    = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    iam_bindings_additive = optional(map(object({
      member = string
      role   = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    id = optional(string)
    values = optional(map(object({
      description = optional(string, "Managed by the Terraform organization module.")
      iam         = optional(map(list(string)), {})
      iam_bindings = optional(map(object({
        members = list(string)
        role    = string
        condition = optional(object({
          expression  = string
          title       = string
          description = optional(string)
        }))
      })), {})
      iam_bindings_additive = optional(map(object({
        member = string
        role   = string
        condition = optional(object({
          expression  = string
          title       = string
          description = optional(string)
        }))
      })), {})
      id = optional(string)
    })), {})
  }))
  nullable = false
  default  = {}
  validation {
    condition = (
      # all keys are non-null
      alltrue([
        for k, v in var.tags : v != null
      ]) &&
      # all values are non-null
      alltrue(flatten([
        for k, v in var.tags : [for k2, v2 in v.values : v2 != null]
      ]))
    )
    error_message = "Use an empty map instead of null as value."
  }
}

variable "deny_policies" {
  description = "Map of deny policies to create. Key = policy_id or name suffix."
  type = map(object({
    parent       = string
    display_name = optional(string)
    name         = string
    rules = list(object({
      denied_principals     = optional(list(string))
      exception_principals  = optional(list(string))
      denied_permissions    = optional(list(string))
      exception_permissions = optional(list(string))
      denial_condition = optional(object({
        title       = optional(string)
        description = optional(string)
        expression  = string
      }))
    }))
  }))
  default = {}
}

variable "dynamic_custom_roles" {
  description = "Object of dynamic custom role"
  type = map(object({
    parents_roles       = list(string)
    exclude_permissions = list(string)
    role_title          = string
    role_description    = string
    attached_to         = optional(list(string))
  }))
  default  = {}
  nullable = false
}

variable "project" {
  description = "The project ID to host the vpc in"
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
}

variable "vpc_name" {
  description = "The name of shared VPC to create"
  type        = string
}

variable "subnets" {
  description = "Subnet configuration."
  type = list(object({
    name                  = string
    ip_cidr_range         = string
    region                = string
    description           = optional(string)
    enable_private_access = optional(bool, true)
    flow_logs_config = optional(object({
      aggregation_interval = optional(string)
      filter_expression    = optional(string)
      flow_sampling        = optional(number)
      metadata             = optional(string)
      # only if metadata == "CUSTOM_METADATA"
      metadata_fields = optional(list(string))
    }))
    ipv6 = optional(object({
      access_type = optional(string, "INTERNAL")
      # this field is marked for internal use in the API documentation
      # enable_private_access = optional(string)
    }))
    secondary_ip_ranges = optional(map(string))

    iam = optional(map(list(string)), {})
    iam_bindings = optional(map(object({
      role    = string
      members = list(string)
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
  }))
  default  = []
  nullable = false
}

variable "subnets_proxy_only" {
  description = "List of proxy-only subnets for Regional HTTPS or Internal HTTPS load balancers. Note: Only one proxy-only subnet for each VPC network in each region can be active."
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    description   = optional(string)
    active        = optional(bool, true)
    global        = optional(bool, false)

    iam = optional(map(list(string)), {})
    iam_bindings = optional(map(object({
      role    = string
      members = list(string)
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
  }))
  default  = []
  nullable = false
}

variable "shared_vpc_host" {
  description = "Enable shared VPC for this project."
  type        = bool
  default     = true
}

variable "shared_vpc_service_projects" {
  description = "Shared VPC service projects to register with this host."
  type        = list(string)
  default     = []
}

variable "subnets_psc" {
  description = "List of subnets for Private Service Connect service producers."
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    description   = optional(string)
  }))
  default = []
}

variable "psa_configs" {
  description = "The Private Service Access configuration."
  type = list(object({
    deletion_policy  = optional(string, null)
    ranges           = map(string)
    export_routes    = optional(bool, false)
    import_routes    = optional(bool, false)
    peered_domains   = optional(list(string), [])
    range_prefix     = optional(string)
    service_producer = optional(string, "servicenetworking.googleapis.com")
  }))
  nullable = false
  default  = []
  validation {
    condition = (
      length(var.psa_configs) == length(toset([
        for v in var.psa_configs : v.service_producer
      ]))
    )
    error_message = "At most one configuration is possible for each service producer."
  }
  validation {
    condition = alltrue([
      for v in var.psa_configs : (
        v.deletion_policy == null || v.deletion_policy == "ABANDON"
      )
    ])
    error_message = "Deletion policy supports only ABANDON."
  }
}

variable "cloud_nat" {
  description = "Cloud Nat's to create for networks"
  type = list(object({
    name                                = string
    region                              = string
    addresses                           = optional(list(string))
    external_address_name               = string
    enable_endpoint_independent_mapping = optional(bool)
    config_min_ports_per_vm             = optional(number, 64)
    config_port_allocation = optional(object({
      enable_endpoint_independent_mapping = optional(bool, true)
      enable_dynamic_port_allocation      = optional(bool, false)
      min_ports_per_vm                    = optional(number, 64)
      max_ports_per_vm                    = optional(number, 65536)
      })
    )
    config_source_subnets = optional(object({
      all                 = optional(bool, true)
      primary_ranges_only = optional(bool)
      subnetworks = optional(list(object({
        self_link        = string
        all_ranges       = optional(bool, true)
        primary_range    = optional(bool, false)
        secondary_ranges = optional(list(string))
      })), [])
    }))

    config_timeouts = optional(object({
      icmp            = number
      tcp_established = number
      tcp_transitory  = number
      udp             = number
      }), {
      icmp            = 30
      tcp_established = 1200
      tcp_transitory  = 30
      udp             = 30
    })
    logging_filter = optional(string)
    router_asn     = optional(number)
    router_create  = optional(bool)

    router_name    = optional(string)
    router_network = optional(string)
    subnetworks = optional(list(object({
      self_link            = string,
      config_source_ranges = list(string)
      secondary_ranges     = list(string)
    })))

  }))
  default = []
}

variable "default_rules_config" {
  description = "Optionally created convenience rules. Set the 'disabled' attribute to true, or individual rule attributes to empty lists to disable."
  type = object({
    admin_ranges = optional(list(string))
    disabled     = optional(bool, false)
    http_ranges = optional(list(string), [
      "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
    )
    http_tags = optional(list(string), ["http-server"])
    https_ranges = optional(list(string), [
      "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
    )
    https_tags = optional(list(string), ["https-server"])
    ssh_ranges = optional(list(string), ["35.235.240.0/20"])
    ssh_tags   = optional(list(string), ["ssh"])
  })
  default  = {}
  nullable = false
}

variable "egress_rules" {
  description = "List of egress rule definitions, default to deny action. Null destination ranges will be replaced with 0/0."
  type = map(object({
    deny               = optional(bool, true)
    description        = optional(string)
    destination_ranges = optional(list(string))
    disabled           = optional(bool, false)
    enable_logging = optional(object({
      include_metadata = optional(bool)
    }))
    priority             = optional(number, 1000)
    targets              = optional(list(string))
    use_service_accounts = optional(bool, false)
    rules = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [{ protocol = "all" }])
  }))
  default  = {}
  nullable = false
}

variable "ingress_rules" {
  description = "List of ingress rule definitions, default to allow action. Null source ranges will be replaced with 0/0."
  type = map(object({
    deny        = optional(bool, false)
    description = optional(string)
    disabled    = optional(bool, false)
    enable_logging = optional(object({
      include_metadata = optional(bool)
    }))
    priority             = optional(number, 1000)
    source_ranges        = optional(list(string))
    destination_ranges   = optional(list(string))
    sources              = optional(list(string))
    targets              = optional(list(string))
    use_service_accounts = optional(bool, false)
    rules = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [{ protocol = "all" }])
  }))
  default  = {}
  nullable = false
}

variable "create_googleapis_routes" {
  description = "Toggle creation of googleapis private/restricted routes. Disabled when vpc creation is turned off, or when set to null."
  type = object({
    directpath   = optional(bool, false)
    directpath-6 = optional(bool, false)
    private      = optional(bool, true)
    private-6    = optional(bool, false)
    restricted   = optional(bool, true)
    restricted-6 = optional(bool, false)
  })
  default = {}
}

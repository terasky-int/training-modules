variable "backend_buckets_config" {
  description = "Backend buckets configuration."
  type = map(object({
    bucket_name             = string
    compression_mode        = optional(string)
    custom_response_headers = optional(list(string))
    description             = optional(string)
    edge_security_policy    = optional(string)
    enable_cdn              = optional(bool)
    project_id              = optional(string)
    cdn_policy = optional(object({
      bypass_cache_on_request_headers = optional(list(string))
      cache_mode                      = optional(string)
      client_ttl                      = optional(number)
      default_ttl                     = optional(number)
      max_ttl                         = optional(number)
      negative_caching                = optional(bool)
      request_coalescing              = optional(bool)
      serve_while_stale               = optional(number)
      signed_url_cache_max_age_sec    = optional(number)
      cache_key_policy = optional(object({
        include_http_headers   = optional(list(string))
        query_string_whitelist = optional(list(string))
      }))
      negative_caching_policy = optional(object({
        code = optional(number)
        ttl  = optional(number)
      }))
    }))
  }))
  default  = {}
  nullable = true
}

variable "description" {
  description = "Optional description used for resources."
  type        = string
  default     = "Terraform managed."
}

variable "forwarding_rules_config" {
  description = "The optional forwarding rules configuration."
  type = map(object({
    address     = optional(string)
    description = optional(string, "Terraform managed.")
    ipv6        = optional(bool, false)
    name        = optional(string)
    ports       = optional(list(number), null)
  }))
  default = {
    "" = {}
  }
  validation {
    condition = alltrue([
      for k, v in var.forwarding_rules_config :
      v.ports == null || (length(coalesce(v.ports, [])) <= 1)
    ])
    error_message = "Application Load Balancer supports at most one port per forwarding rule."
  }
}

variable "group_configs" {
  description = "Optional unmanaged groups to create. Can be referenced in backends via key or outputs."
  type = map(object({
    zone        = string
    instances   = optional(list(string))
    named_ports = optional(map(number), {})
    project_id  = optional(string)
  }))
  default  = {}
  nullable = false
}

variable "https_proxy_config" {
  description = "HTTPS proxy connfiguration."
  type = object({
    name                             = optional(string)
    description                      = optional(string, "Terraform managed.")
    certificate_manager_certificates = optional(list(string))
    certificate_map                  = optional(string)
    quic_override                    = optional(string)
    ssl_policy                       = optional(string)
    mtls_policy                      = optional(string) # id of the mTLS policy to use for the target proxy.
  })
  default  = {}
  nullable = false
}

variable "labels" {
  description = "Labels set on resources."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Load balancer name."
  type        = string
}

variable "neg_configs" {
  description = "Optional network endpoint groups to create. Can be referenced in backends via key or outputs."
  type = map(object({
    project_id  = optional(string)
    description = optional(string)
    cloudfunction = optional(object({
      region          = string
      target_function = optional(string)
      target_urlmask  = optional(string)
    }))
    cloudrun = optional(object({
      region = string
      target_service = optional(object({
        name = string
        tag  = optional(string)
      }))
      target_urlmask = optional(string)
    }))
    gce = optional(object({
      network    = string
      subnetwork = string
      zone       = string
      # default_port = optional(number)
      endpoints = optional(map(object({
        instance   = string
        ip_address = string
        port       = number
      })))
    }))
    hybrid = optional(object({
      network = string
      zone    = string
      # re-enable once provider properly support this
      # default_port = optional(number)
      endpoints = optional(map(object({
        ip_address = string
        port       = number
      })))
    }))
    internet = optional(object({
      use_fqdn = optional(bool, true)
      # re-enable once provider properly support this
      # default_port = optional(number)
      endpoints = optional(map(object({
        destination = string
        port        = number
      })))
    }))
    psc = optional(object({
      region         = string
      target_service = string
      network        = optional(string)
      subnetwork     = optional(string)
    }))
    predefined = optional(object({
      id = string
    }))
  }))
  default  = {}
  nullable = false
  validation {
    condition = alltrue([
      for k, v in var.neg_configs : (
        (try(v.cloudfunction, null) == null ? 0 : 1) +
        (try(v.cloudrun, null) == null ? 0 : 1) +
        (try(v.gce, null) == null ? 0 : 1) +
        (try(v.hybrid, null) == null ? 0 : 1) +
        (try(v.internet, null) == null ? 0 : 1) +
        (try(v.psc, null) == null ? 0 : 1) == 1
      )
    ])
    error_message = "Only one type of NEG can be configured at a time."
  }
  validation {
    condition = alltrue([
      for k, v in var.neg_configs : (
        v.cloudrun == null
        ? true
        : v.cloudrun.target_urlmask != null || v.cloudrun.target_service != null
      )
    ])
    error_message = "Cloud Run NEGs need either target service or target urlmask defined."
  }
  validation {
    condition = alltrue([
      for k, v in var.neg_configs : (
        v.cloudfunction == null
        ? true
        : v.cloudfunction.target_urlmask != null || v.cloudfunction.target_function != null
      )
    ])
    error_message = "Cloud Function NEGs need either target function or target urlmask defined."
  }
}

variable "project_id" {
  description = "Project id."
  type        = string
}

variable "protocol" {
  description = "Protocol supported by this load balancer."
  type        = string
  default     = "HTTP"
  nullable    = false
  validation {
    condition = (
      var.protocol == null || var.protocol == "HTTP" || var.protocol == "HTTPS"
    )
    error_message = "Protocol must be HTTP or HTTPS"
  }
}

variable "ssl_certificates" {
  description = "SSL target proxy certificates (only if protocol is HTTPS) for existing, custom, and managed certificates."
  type = object({
    certificate_ids = optional(list(string), [])
    create_configs = optional(map(object({
      certificate = string
      private_key = string
    })), {})
    managed_configs = optional(map(object({
      name        = optional(string)
      domains     = list(string)
      description = optional(string)
    })), {})
  })
  default  = {}
  nullable = false
}

variable "use_classic_version" {
  description = "Use classic Global Load Balancer."
  type        = bool
  default     = true
}

variable "created_negs" {
  description = "IDs of negs in map"
  type        = map(any)
  default     = {}
}

variable "backend_service_configs" {
  description = "Backend service level configuration."
  type = map(object({
    name                            = optional(string)
    description                     = optional(string, "Terraform managed.")
    affinity_cookie_ttl_sec         = optional(number)
    compression_mode                = optional(string)
    connection_draining_timeout_sec = optional(number)
    custom_request_headers          = optional(list(string))
    custom_response_headers         = optional(list(string))
    enable_cdn                      = optional(bool)
    health_checks                   = optional(list(string), ["default"])
    log_sample_rate                 = optional(number)
    locality_lb_policy              = optional(string)
    port_name                       = optional(string)
    project_id                      = optional(string)
    protocol                        = optional(string, "HTTP")
    security_policy                 = optional(string)
    edge_security_policy            = optional(string)
    session_affinity                = optional(string)
    timeout_sec                     = optional(number)
    backends = list(object({
      # group renamed to backend
      backend         = string
      preferred       = optional(bool, false)
      balancing_mode  = optional(string, "UTILIZATION")
      capacity_scaler = optional(number, 1)
      description     = optional(string, "Terraform managed.")
      failover        = optional(bool, false)
      max_connections = optional(object({
        per_endpoint = optional(number)
        per_group    = optional(number)
        per_instance = optional(number)
      }))
      max_rate = optional(object({
        per_endpoint = optional(number)
        per_group    = optional(number)
        per_instance = optional(number)
      }))
      max_utilization = optional(number)
    }))
    cdn_policy = optional(object({
      cache_mode                   = optional(string)
      client_ttl                   = optional(number)
      default_ttl                  = optional(number)
      max_ttl                      = optional(number)
      negative_caching             = optional(bool)
      serve_while_stale            = optional(number)
      signed_url_cache_max_age_sec = optional(number)
      cache_key_policy = optional(object({
        include_host           = optional(bool)
        include_named_cookies  = optional(list(string))
        include_protocol       = optional(bool)
        include_query_string   = optional(bool)
        query_string_blacklist = optional(list(string))
        query_string_whitelist = optional(list(string))
      }))
      negative_caching_policy = optional(object({
        code = optional(number)
        ttl  = optional(number)
      }))
    }))
    circuit_breakers = optional(object({
      max_connections             = optional(number)
      max_pending_requests        = optional(number)
      max_requests                = optional(number)
      max_requests_per_connection = optional(number)
      max_retries                 = optional(number)
      connect_timeout = optional(object({
        seconds = number
        nanos   = optional(number)
      }))
    }))
    consistent_hash = optional(object({
      http_header_name  = optional(string)
      minimum_ring_size = optional(number)
      http_cookie = optional(object({
        name = optional(string)
        path = optional(string)
        ttl = optional(object({
          seconds = number
          nanos   = optional(number)
        }))
      }))
    }))
    iap_config = optional(object({
      oauth2_client_id            = optional(string)
      oauth2_client_secret        = optional(string)
      oauth2_client_secret_sha256 = optional(string)
    }))
    locality_lb_policies = optional(list(object({
      policy = optional(object({
        name = string
      }))
      custom_policy = optional(object({
        name = string
        data = optional(string)
      }))
    })))
    outlier_detection = optional(object({
      consecutive_errors                    = optional(number)
      consecutive_gateway_failure           = optional(number)
      enforcing_consecutive_errors          = optional(number)
      enforcing_consecutive_gateway_failure = optional(number)
      enforcing_success_rate                = optional(number)
      max_ejection_percent                  = optional(number)
      success_rate_minimum_hosts            = optional(number)
      success_rate_request_volume           = optional(number)
      success_rate_stdev_factor             = optional(number)
      base_ejection_time = optional(object({
        seconds = number
        nanos   = optional(number)
      }))
      interval = optional(object({
        seconds = number
        nanos   = optional(number)
      }))
    }))
    security_settings = optional(object({
      client_tls_policy = optional(string)
      subject_alt_names = optional(list(string))
      aws_v4_authentication = optional(object({
        access_key_id      = optional(string)
        access_key         = optional(string)
        access_key_version = optional(string)
        origin_region      = optional(string)
      }))
  })) }))
  default  = {}
  nullable = false
  validation {
    condition = alltrue([
      for backend_service in values(var.backend_service_configs) : contains(
        [
          "NONE", "CLIENT_IP", "CLIENT_IP_NO_DESTINATION",
          "CLIENT_IP_PORT_PROTO", "CLIENT_IP_PROTO",
          "GENERATED_COOKIE", "HEADER_FIELD", "HTTP_COOKIE",
          "STRONG_COOKIE_AFFINITY"
        ],
        coalesce(backend_service.session_affinity, "NONE")
      )
    ])
    error_message = "Invalid session affinity value."
  }
  validation {
    condition = alltrue(flatten([
      for backend_service in values(var.backend_service_configs) : [
        for backend in backend_service.backends : contains(
          ["RATE", "UTILIZATION"], coalesce(backend.balancing_mode, "UTILIZATION")
      )]
    ]))
    error_message = "When specified, balancing mode needs to be 'RATE' or 'UTILIZATION'."
  }
  validation {
    condition = alltrue([
      for backend_service in values(var.backend_service_configs) :
      (backend_service.locality_lb_policy == null ? true :
        contains(
          [
            "ROUND_ROBIN", "LEAST_REQUEST", "RING_HASH", "RANDOM",
            "ORIGINAL_DESTINATION", "MAGLEV"
          ],
          backend_service.locality_lb_policy
      ))
    ])
    error_message = "When specified, locality lb policy must be one of : 'ROUND_ROBIN', 'LEAST_REQUEST', 'RING_HASH', 'RANDOM', 'ORIGINAL_DESTINATION', 'MAGLEV', 'WEIGHTED_MAGLEV'."
  }
  validation {
    condition = alltrue(flatten([
      for backend_service in values(var.backend_service_configs) : [
        for llp in coalesce(backend_service.locality_lb_policies, []) : (
          ((llp.policy != null && llp.custom_policy == null) || (llp.policy == null && llp.custom_policy != null))
        )
      ]
    ]))
    error_message = "When specified, all locality lb polcies must have EITHER policy or custom_policy filled, not both."
  }
}

variable "health_check_configs" {
  description = "Optional auto-created health check configurations, use the output self-link to set it in the auto healing policy. Refer to examples for usage."
  type = map(object({
    name                = optional(string)
    check_interval_sec  = optional(number)
    description         = optional(string, "Terraform managed.")
    enable_logging      = optional(bool, true)
    healthy_threshold   = optional(number)
    project_id          = optional(string)
    timeout_sec         = optional(number)
    unhealthy_threshold = optional(number)
    grpc = optional(object({
      port               = optional(number)
      port_name          = optional(string)
      port_specification = optional(string) # USE_FIXED_PORT USE_NAMED_PORT USE_SERVING_PORT
      service_name       = optional(string)
    }))
    http = optional(object({
      host               = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      port_specification = optional(string) # USE_FIXED_PORT USE_NAMED_PORT USE_SERVING_PORT
      proxy_header       = optional(string)
      request_path       = optional(string)
      response           = optional(string)
    }))
    http2 = optional(object({
      host               = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      port_specification = optional(string) # USE_FIXED_PORT USE_NAMED_PORT USE_SERVING_PORT
      proxy_header       = optional(string)
      request_path       = optional(string)
      response           = optional(string)
    }))
    https = optional(object({
      host               = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      port_specification = optional(string) # USE_FIXED_PORT USE_NAMED_PORT USE_SERVING_PORT
      proxy_header       = optional(string)
      request_path       = optional(string)
      response           = optional(string)
    }))
    tcp = optional(object({
      port               = optional(number)
      port_name          = optional(string)
      port_specification = optional(string) # USE_FIXED_PORT USE_NAMED_PORT USE_SERVING_PORT
      proxy_header       = optional(string)
      request            = optional(string)
      response           = optional(string)
    }))
    ssl = optional(object({
      port               = optional(number)
      port_name          = optional(string)
      port_specification = optional(string) # USE_FIXED_PORT USE_NAMED_PORT USE_SERVING_PORT
      proxy_header       = optional(string)
      request            = optional(string)
      response           = optional(string)
    }))
  }))
  default = {
    default = {
      http = {
        port_specification = "USE_SERVING_PORT"
      }
    }
  }
  validation {
    condition = alltrue([
      for k, v in var.health_check_configs : (
        (try(v.grpc, null) == null ? 0 : 1) +
        (try(v.http, null) == null ? 0 : 1) +
        (try(v.http2, null) == null ? 0 : 1) +
        (try(v.https, null) == null ? 0 : 1) +
        (try(v.tcp, null) == null ? 0 : 1) +
        (try(v.ssl, null) == null ? 0 : 1) <= 1
      )
    ])
    error_message = "At most one health check type can be configured at a time."
  }
  validation {
    condition = alltrue(flatten([
      for k, v in var.health_check_configs : [
        for kk, vv in v : contains([
          "-", "USE_FIXED_PORT", "USE_NAMED_PORT", "USE_SERVING_PORT"
        ], coalesce(try(vv.port_specification, null), "-"))
      ]
    ]))
    error_message = "Invalid 'port_specification' value. Supported values are 'USE_FIXED_PORT', 'USE_NAMED_PORT', 'USE_SERVING_PORT'."
  }
}

variable "urlmap_config" {
  description = "The URL map configuration."
  type = object({
    description = optional(string, "Terraform managed.")
    default_custom_error_response_policy = optional(object({
      error_service = optional(string)
      error_response_rules = optional(list(object({
        match_response_codes   = optional(list(string))
        path                   = optional(string)
        override_response_code = optional(number)
      })))
    }))
    default_route_action = optional(object({
      request_mirror_backend = optional(string)
      cors_policy = optional(object({
        allow_credentials    = optional(bool)
        allow_headers        = optional(list(string))
        allow_methods        = optional(list(string))
        allow_origin_regexes = optional(list(string))
        allow_origins        = optional(list(string))
        disabled             = optional(bool)
        expose_headers       = optional(list(string))
        max_age              = optional(string)
      }))
      fault_injection_policy = optional(object({
        abort = optional(object({
          percentage = number
          status     = number
        }))
        delay = optional(object({
          fixed = object({
            seconds = number
            nanos   = number
          })
          percentage = number
        }))
      }))
      retry_policy = optional(object({
        num_retries      = number
        retry_conditions = optional(list(string))
        per_try_timeout = optional(object({
          seconds = number
          nanos   = optional(number)
        }))
      }))
      timeout = optional(object({
        seconds = number
        nanos   = optional(number)
      }))
      url_rewrite = optional(object({
        host          = optional(string)
        path_prefix   = optional(string)
        path_template = optional(string)
      }))
      weighted_backend_services = optional(map(object({
        weight = number
        header_action = optional(object({
          request_add = optional(map(object({
            value   = string
            replace = optional(bool, true)
          })))
          request_remove = optional(list(string))
          response_add = optional(map(object({
            value   = string
            replace = optional(bool, true)
          })))
          response_remove = optional(list(string))
        }))
      })))
    }))
    default_service = optional(string)
    default_url_redirect = optional(object({
      host          = optional(string)
      https         = optional(bool)
      path          = optional(string)
      prefix        = optional(string)
      response_code = optional(string)
      strip_query   = optional(bool, false)
    }))
    header_action = optional(object({
      request_add = optional(map(object({
        value   = string
        replace = optional(bool, true)
      })))
      request_remove = optional(list(string))
      response_add = optional(map(object({
        value   = string
        replace = optional(bool, true)
      })))
      response_remove = optional(list(string))
    }))
    host_rules = optional(list(object({
      hosts        = list(string)
      path_matcher = string
      description  = optional(string)
    })))
    path_matchers = optional(map(object({
      description = optional(string)
      default_custom_error_response_policy = optional(object({
        error_service = optional(string)
        error_response_rules = optional(list(object({
          match_response_codes   = optional(list(string))
          path                   = optional(string)
          override_response_code = optional(number)
        })))
      }))
      default_route_action = optional(object({
        request_mirror_backend = optional(string)
        cors_policy = optional(object({
          allow_credentials    = optional(bool)
          allow_headers        = optional(list(string))
          allow_methods        = optional(list(string))
          allow_origin_regexes = optional(list(string))
          allow_origins        = optional(list(string))
          disabled             = optional(bool)
          expose_headers       = optional(list(string))
          max_age              = optional(string)
        }))
        fault_injection_policy = optional(object({
          abort = optional(object({
            percentage = number
            status     = number
          }))
          delay = optional(object({
            fixed = object({
              seconds = number
              nanos   = number
            })
            percentage = number
          }))
        }))
        retry_policy = optional(object({
          num_retries      = number
          retry_conditions = optional(list(string))
          per_try_timeout = optional(object({
            seconds = number
            nanos   = optional(number)
          }))
        }))
        timeout = optional(object({
          seconds = number
          nanos   = optional(number)
        }))
        url_rewrite = optional(object({
          host        = optional(string)
          path_prefix = optional(string)
        }))
        weighted_backend_services = optional(map(object({
          weight = number
          header_action = optional(object({
            request_add = optional(map(object({
              value   = string
              replace = optional(bool, true)
            })))
            request_remove = optional(list(string))
            response_add = optional(map(object({
              value   = string
              replace = optional(bool, true)
            })))
            response_remove = optional(list(string))
          }))
        })))
      }))
      default_service = optional(string)
      default_url_redirect = optional(object({
        host          = optional(string)
        https         = optional(bool)
        path          = optional(string)
        prefix        = optional(string)
        response_code = optional(string)
        strip_query   = optional(bool)
      }))
      header_action = optional(object({
        request_add = optional(map(object({
          value   = string
          replace = optional(bool, true)
        })))
        request_remove = optional(list(string))
        response_add = optional(map(object({
          value   = string
          replace = optional(bool, true)
        })))
        response_remove = optional(list(string))
      }))
      path_rules = optional(list(object({
        paths   = list(string)
        service = optional(string)
        custom_error_response_policy = optional(object({
          error_service = optional(string)
          error_response_rules = optional(list(object({
            match_response_codes   = optional(list(string))
            path                   = optional(string)
            override_response_code = optional(number)
          })))
        }))
        route_action = optional(object({
          request_mirror_backend = optional(string)
          cors_policy = optional(object({
            allow_credentials    = optional(bool)
            allow_headers        = optional(string)
            allow_methods        = optional(string)
            allow_origin_regexes = list(string)
            allow_origins        = list(string)
            disabled             = optional(bool)
            expose_headers       = optional(string)
            max_age              = optional(string)
          }))
          fault_injection_policy = optional(object({
            abort = optional(object({
              percentage = number
              status     = number
            }))
            delay = optional(object({
              fixed = object({
                seconds = number
                nanos   = number
              })
              percentage = number
            }))
          }))
          retry_policy = optional(object({
            num_retries      = number
            retry_conditions = optional(list(string))
            per_try_timeout = optional(object({
              seconds = number
              nanos   = optional(number)
            }))
          }))
          timeout = optional(object({
            seconds = number
            nanos   = optional(number)
          }))
          url_rewrite = optional(object({
            host        = optional(string)
            path_prefix = optional(string)
          }))
          weighted_backend_services = optional(map(object({
            weight = number
            header_action = optional(object({
              request_add = optional(map(object({
                value   = string
                replace = optional(bool, true)
              })))
              request_remove = optional(list(string))
              response_add = optional(map(object({
                value   = string
                replace = optional(bool, true)
              })))
              response_remove = optional(list(string))
            }))
          })))
        }))
        url_redirect = optional(object({
          host          = optional(string)
          https         = optional(bool)
          path          = optional(string)
          prefix        = optional(string)
          response_code = optional(string)
          strip_query   = optional(bool)
        }))
      })))
      route_rules = optional(list(object({
        priority = number
        service  = optional(string)
        header_action = optional(object({
          request_add = optional(map(object({
            value   = string
            replace = optional(bool, true)
          })))
          request_remove = optional(list(string))
          response_add = optional(map(object({
            value   = string
            replace = optional(bool, true)
          })))
          response_remove = optional(list(string))
        }))
        match_rules = optional(list(object({
          ignore_case = optional(bool, false)
          headers = optional(list(object({
            name         = string
            invert_match = optional(bool, false)
            type         = optional(string, "present") # exact, prefix, suffix, regex, present, range, template
            value        = optional(string)
            range_value = optional(object({
              end   = string
              start = string
            }))
          })))
          metadata_filters = optional(list(object({
            labels    = map(string)
            match_all = bool # MATCH_ANY, MATCH_ALL
          })))
          path = optional(object({
            value = string
            type  = optional(string, "prefix") # full, prefix, regex
          }))
          query_params = optional(list(object({
            name  = string
            value = string
            type  = optional(string, "present") # exact, present, regex
          })))
        })))
        route_action = optional(object({
          request_mirror_backend = optional(string)
          cors_policy = optional(object({
            allow_credentials    = optional(bool)
            allow_headers        = optional(string)
            allow_methods        = optional(string)
            allow_origin_regexes = list(string)
            allow_origins        = list(string)
            disabled             = optional(bool)
            expose_headers       = optional(string)
            max_age              = optional(string)
          }))
          fault_injection_policy = optional(object({
            abort = optional(object({
              percentage = number
              status     = number
            }))
            delay = optional(object({
              fixed = object({
                seconds = number
                nanos   = number
              })
              percentage = number
            }))
          }))
          retry_policy = optional(object({
            num_retries      = number
            retry_conditions = optional(list(string))
            per_try_timeout = optional(object({
              seconds = number
              nanos   = optional(number)
            }))
          }))
          timeout = optional(object({
            seconds = number
            nanos   = optional(number)
          }))
          url_rewrite = optional(object({
            host          = optional(string)
            path_prefix   = optional(string)
            path_template = optional(string)
          }))
          weighted_backend_services = optional(map(object({
            weight = number
            header_action = optional(object({
              request_add = optional(map(object({
                value   = string
                replace = optional(bool, true)
              })))
              request_remove = optional(list(string))
              response_add = optional(map(object({
                value   = string
                replace = optional(bool, true)
              })))
              response_remove = optional(list(string))
            }))
          })))
        }))
        url_redirect = optional(object({
          host          = optional(string)
          https         = optional(bool)
          path          = optional(string)
          prefix        = optional(string)
          response_code = optional(string)
          strip_query   = optional(bool)
        }))
      })))
    })))
    test = optional(list(object({
      host        = string
      path        = string
      service     = string
      description = optional(string)
    })))
  })
  default = {
    default_service = "default"
  }
}

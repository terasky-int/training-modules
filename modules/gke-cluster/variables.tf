# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "location" {
  description = "The location (region or zone) to host the cluster in"
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
}

variable "name" {
  description = "The name of the cluster"
  type        = string
}

variable "network" {
  description = "A reference (self link) to the VPC network to host the cluster in"
  type        = string
}

variable "subnetwork" {
  description = "A reference (self link) to the subnetwork to host the cluster in"
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "Predefined range name for the cluster pod IPs."
  type        = string
}
variable "service_secondary_range_name" {
  description = "Predefined range name for the cluster services IPs."
  type        = string
}

# variable "nodepool_config" {
#   description = "Nodepool-level configuration."
#   type = object({
#     autoscaling = optional(object({
#       location_policy = optional(string)
#       max_node_count  = optional(number)
#       min_node_count  = optional(number)
#       use_total_nodes = optional(bool, false)
#     }))
#     management = optional(object({
#       auto_repair  = optional(bool)
#       auto_upgrade = optional(bool)
#     }))
#     # placement_policy = optional(bool)
#     upgrade_settings = optional(object({
#       max_surge       = number
#       max_unavailable = number
#     }))
#   })
#   default = null
# }

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

variable "description" {
  description = "The description of the cluster"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "The Kubernetes version of the masters. If set to 'latest' it will pull latest available version in the selected region."
  type        = string
  default     = "latest"
}

variable "horizontal_pod_autoscaling" {
  description = "Whether to enable the horizontal pod autoscaling addon"
  type        = bool
  default     = true
}

variable "http_load_balancing" {
  description = "Whether to enable the http (L7) load balancing addon"
  type        = bool
  default     = true
}

variable "enable_private_nodes" {
  description = "Control whether nodes have internal IP addresses only. If enabled, all nodes are given only RFC 1918 private addresses and communicate with the master via private networking."
  type        = bool
  default     = false
}

variable "disable_public_endpoint" {
  description = "Control whether the master's internal IP address is used as the cluster endpoint. If set to 'true', the master can only be accessed from internal IP addresses."
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning internal IP addresses to the master or set of masters, as well as the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network."
  type        = string
  default     = ""
}

variable "master_authorized_networks_config" {
  description = <<EOF
  The desired configuration options for master authorized networks. Omit the nested cidr_blocks attribute to disallow external access (except the cluster node IPs, which GKE automatically whitelists)
  ### example format ###
  master_authorized_networks_config = [{
    cidr_blocks = [{
      cidr_block   = "10.0.0.0/8"
      display_name = "example_network"
    }],
  }]
EOF
  type        = list(any)
  default     = []
}

variable "maintenance_start_time" {
  description = "Time window specified for daily maintenance operations in RFC3339 format"
  type        = string
  default     = "05:00"
}

variable "alternative_default_service_account" {
  description = "Alternative Service Account to be used by the Node VMs. If not specified, the default compute Service Account will be used. Provide if the default Service Account is no longer available."
  type        = string
  default     = null
}

variable "resource_labels" {
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster."
  type        = map(any)
  default     = {}
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS - RECOMMENDED DEFAULTS
# These values shouldn't be changed; they're following the best practices defined at https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster
# ---------------------------------------------------------------------------------------------------------------------

variable "enable_legacy_abac" {
  description = "Whether to enable legacy Attribute-Based Access Control (ABAC). RBAC has significant security advantages over ABAC."
  type        = bool
  default     = false
}

variable "enable_dataplane_v2" {
  description = "Whether to enable Kubernetes Dataplane V2 ."
  type        = bool
  default     = true
}

# See https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control#google-groups-for-gke
variable "gsuite_domain_name" {
  description = "The domain name for use with Google security groups in Kubernetes RBAC. If a value is provided, the cluster will be initialized with security group `gke-security-groups@[yourdomain.com]`."
  type        = string
  default     = null
}

variable "enable_secrets_database_encryption" {
  description = "Enable encryption of secrets in etcd, e.g: projects/my-project/locations/global/keyRings/my-ring/cryptoKeys/my-key"
  type        = bool
  default     = true
}

# See https://cloud.google.com/kubernetes-engine/docs/concepts/verticalpodautoscaler
variable "enable_vertical_pod_autoscaling" {
  description = "Whether to enable Vertical Pod Autoscaling"
  type        = string
  default     = false
}


variable "enable_workload_identity" {
  description = "Enable Workload Identity on the cluster"
  default     = false
  type        = bool
}

variable "identity_namespace" {
  description = "Workload Identity Namespace. Default sets project based namespace [project_id].svc.id.goog"
  default     = null
  type        = string
}


variable "env" {
  description = "Environment name where custer is deployed"
  type        = string
}

variable "cluster_service_account_name" {
  description = "The name of the custom service account used for the GKE cluster. This parameter is limited to a maximum of 28 characters."
  type        = string
  default     = "example-private-cluster-sa"
}

variable "cluster_service_account_description" {
  description = "A description of the custom service account used for the GKE cluster."
  type        = string
  default     = "Example GKE Cluster Service Account managed by Terraform"
}

variable "service_account_roles" {
  description = "Service account roles for GKE Cluster"
  type        = list(any)
  default     = []
}

variable "kubernetes_nodes_version" {
  description = "Kubernetes version for worker nodes."
  type        = string
  default     = "latest"
}





variable "machine_type" {
  description = "Type of machines to use on cluster node-private-pool."
  type        = string
  default     = "n1-standard-1"
}

variable "private_tag" {
  description = "The name of private network tagß"
  type        = string
}

variable "preemptible" {
  description = "Do we run cheaper preemptible nodes."
  type        = bool
  default     = false
}


variable "spot" {
  description = "Do we run cheaper spot nodes."
  type        = bool
  default     = false
}

variable "oauth_scopes" {
  description = "Oauth scopes to add for GKE Node pool"
  type        = list(any)
  default     = []
}
variable "node_locations" {
  description = "The list of zones in which the cluster's nodes are located. Nodes must be in the region of their regional cluster or in the same region as their cluster's zone for zonal clusters. If this is specified for a zonal cluster, omit the cluster's zone."
  type        = list(any)
  default     = []
}

variable "sufix" {
  type        = string
  description = "Sufix for naming. Default value is empty string"
  default     = ""
}

variable "enable_gateway_api" {
  type        = bool
  description = "(Optional)Enable Configuration for GKE Gateway API controller. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_gateway_api_config:~:text=GKE%20Gateway%20API%20controller"
  default     = false
}

variable "node_pools" {
  type = map(object({
    name              = string
    nodepool_version  = optional(string)
    max_pods_per_node = optional(number, 110)
    nodepool_config = object({
      autoscaling = optional(object({
        location_policy = optional(string)
        max_node_count  = optional(number)
        min_node_count  = optional(number)
        use_total_nodes = optional(bool, false)
      }))
      management = optional(object({
        auto_repair  = optional(bool)
        auto_upgrade = optional(bool)
      }))
      # placement_policy = optional(bool)
      upgrade_settings = optional(object({
        max_surge       = number
        max_unavailable = number
      }))
      labels = map(string)
    })
    nodepool_locations    = optional(list(string))
    nodepool_image_type   = optional(string)
    nodepool_machine_type = string
    guest_accelerator = optional(list(object({
      type  = string
      count = number
    })))
    disk_size_gb         = string
    disk_type            = string
    nodepool_preemptible = bool
    nodepool_spot        = bool
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  description = "Node pool configuration."
  default     = {}
}

variable "artifact_registry_project" {
  description = "Can specify extra artifact registry project where it's deployed to add GKE sa Artifact Registry Reader role"
  type        = string
  default     = null
}

variable "access_config_dns_access" {
  description = "Controls whether user traffic is allowed over this endpoint. Note that GCP-managed services may still use the endpoint even if this is false."
  type        = bool
  default     = true
}

variable "enable_l4_ilb_subsetting" {
  description = "(Optional) Whether L4ILB Subsetting is enabled for this cluster."
  type        = bool
  default     = true
}

variable "shared_vpc_project" {
  description = "The shared VPC project ID, if any"
  type        = string
  default     = null
}

variable "enable_shielded_nodes" {
  description = "Enable shielded nodes"
  type        = bool
  default     = false
}

variable "monitoring_config" {
  description = "Monitoring configuration. Google Cloud Managed Service for Prometheus is enabled by default."
  type = object({
    enable_system_metrics = optional(bool, true)
    # Control plane metrics
    enable_api_server_metrics         = optional(bool, false)
    enable_controller_manager_metrics = optional(bool, false)
    enable_scheduler_metrics          = optional(bool, false)
    # Kube state metrics
    enable_daemonset_metrics   = optional(bool, false)
    enable_deployment_metrics  = optional(bool, false)
    enable_hpa_metrics         = optional(bool, false)
    enable_pod_metrics         = optional(bool, false)
    enable_statefulset_metrics = optional(bool, false)
    enable_storage_metrics     = optional(bool, false)
    enable_cadvisor_metrics    = optional(bool, false)
    # Google Cloud Managed Service for Prometheus
    enable_managed_prometheus = optional(bool, true)
    advanced_datapath_observability = optional(object({
      enable_metrics = bool
      enable_relay   = bool
    }))
  })
  default  = {}
  nullable = false
  validation {
    condition = anytrue([
      var.monitoring_config.enable_api_server_metrics,
      var.monitoring_config.enable_controller_manager_metrics,
      var.monitoring_config.enable_scheduler_metrics,
      var.monitoring_config.enable_daemonset_metrics,
      var.monitoring_config.enable_deployment_metrics,
      var.monitoring_config.enable_hpa_metrics,
      var.monitoring_config.enable_pod_metrics,
      var.monitoring_config.enable_statefulset_metrics,
      var.monitoring_config.enable_storage_metrics,
      var.monitoring_config.enable_cadvisor_metrics,
    ]) ? var.monitoring_config.enable_system_metrics : true
    error_message = "System metrics are the minimum required component for enabling metrics collection."
  }
  validation {
    condition = anytrue([
      var.monitoring_config.enable_daemonset_metrics,
      var.monitoring_config.enable_deployment_metrics,
      var.monitoring_config.enable_hpa_metrics,
      var.monitoring_config.enable_pod_metrics,
      var.monitoring_config.enable_statefulset_metrics,
      var.monitoring_config.enable_storage_metrics,
      var.monitoring_config.enable_cadvisor_metrics,
    ]) ? var.monitoring_config.enable_managed_prometheus : true
    error_message = "Kube state metrics collection requires Google Cloud Managed Service for Prometheus to be enabled."
  }
}

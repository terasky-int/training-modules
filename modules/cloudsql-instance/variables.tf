
variable "allocated_ip_ranges" {
  description = "(Optional)The name of the allocated ip range for the private ip CloudSQL instance. For example: \"google-managed-services-default\". If set, the instance ip will be created in the allocated range. The range name must comply with RFC 1035. Specifically, the name must be 1-63 characters long and match the regular expression a-z?."
  type = object({
    primary = optional(string)
    replica = optional(string)
  })
  default  = {}
  nullable = false
}

variable "authorized_networks" {
  description = "Map of NAME=>CIDR_RANGE to allow to connect to the database(s)."
  type        = map(string)
  default     = null
}

variable "psc_subnet_name" {
  description = "PSC subnet name where to place ip of cloud sql"
  type        = string
}

variable "psc_vpc_name" {
  description = "PSC vpc name where to place ip of cloud sql"
  type        = string
}

variable "availability_type" {
  description = "Availability type for the primary replica. Either `ZONAL` or `REGIONAL`."
  type        = string
  default     = "ZONAL"
}

variable "backup_configuration" {
  description = "Backup settings for primary instance. Will be automatically enabled if using MySQL with one or more replicas."
  type = object({
    enabled                        = bool
    binary_log_enabled             = bool
    start_time                     = string
    location                       = string
    point_in_time_recovery_enabled = bool
    log_retention_days             = number
    retention_count                = number
  })
  default = {
    enabled                        = true
    binary_log_enabled             = true
    point_in_time_recovery_enabled = true
    start_time                     = "23:00"
    location                       = null
    log_retention_days             = 7
    retention_count                = 7
  }
}

variable "database_version" {
  description = " (Required) The MySQL, PostgreSQL or SQL Server version to use. Supported values include MYSQL_5_6, MYSQL_5_7, MYSQL_8_0, MYSQL_8_4, POSTGRES_9_6,POSTGRES_10, POSTGRES_11, POSTGRES_12, POSTGRES_13, POSTGRES_14, POSTGRES_15, POSTGRES_16, POSTGRES_17, SQLSERVER_2017_STANDARD, SQLSERVER_2017_ENTERPRISE, SQLSERVER_2017_EXPRESS, SQLSERVER_2017_WEB. SQLSERVER_2019_STANDARD, SQLSERVER_2019_ENTERPRISE, SQLSERVER_2019_EXPRESS, SQLSERVER_2019_WEB"
  type        = string
  validation {
    condition = contains([
      "MYSQL_5_6", "MYSQL_5_7", "MYSQL_8_0", "MYSQL_8_4",
      "POSTGRES_9_6", "POSTGRES_10", "POSTGRES_11", "POSTGRES_12",
      "POSTGRES_13", "POSTGRES_14", "POSTGRES_15", "POSTGRES_16", "POSTGRES_17",
      "SQLSERVER_2017_STANDARD", "SQLSERVER_2017_ENTERPRISE", "SQLSERVER_2017_EXPRESS", "SQLSERVER_2017_WEB",
      "SQLSERVER_2019_STANDARD", "SQLSERVER_2019_ENTERPRISE", "SQLSERVER_2019_EXPRESS", "SQLSERVER_2019_WEB"
    ], var.database_version)
    error_message = "Invalid database version. Please choose from the supported values."
  }
}

variable "databases" {
  description = "Databases to create once the primary instance is created."
  type        = list(string)
  default     = null
}

variable "deletion_protection" {
  description = "Allow terraform to delete instances."
  type        = bool
  default     = false
}

variable "disk_size" {
  description = "Disk size in GB. Set to null to enable autoresize."
  type        = number
  default     = null
}

variable "disk_type" {
  description = "The type of data disk: `PD_SSD` or `PD_HDD`."
  type        = string
  default     = "PD_SSD"
}

variable "encryption_key_name" {
  description = "The full path to the encryption key used for the CMEK disk encryption of the primary instance."
  type        = string
  default     = null
}

variable "flags" {
  description = "Map FLAG_NAME=>VALUE for database-specific tuning."
  type        = map(string)
  default     = null
}

variable "ipv4_enabled" {
  description = "Add a public IP address to database instance."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to be attached to all instances."
  type        = map(string)
  default     = null
}

variable "name" {
  description = "Name of primary instance."
  type        = string
}

variable "network" {
  description = "VPC self link where the instances will be deployed. Private Service Networking must be enabled and configured in this VPC."
  type        = string
}

variable "prefix" {
  description = "Optional prefix used to generate instance names."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty, please use null instead."
  }
}

variable "project_id" {
  description = "The ID of the project where this instances will be created."
  type        = string
}

variable "region" {
  description = "Region of the primary instance."
  type        = string
}

variable "replicas" {
  description = "Map of NAME=> {REGION, KMS_KEY} for additional read replicas. Set to null to disable replica creation."
  type = map(object({
    region              = string
    encryption_key_name = string
    database_version    = optional(string)
  }))
  default = {}
}

variable "root_password" {
  description = "Root password of the Cloud SQL instance. Required for MS SQL Server."
  type        = string
  default     = null
}

variable "tier" {
  description = "The machine type to use for the instances."
  type        = string
}

variable "users" {
  description = "Map of users to create in the primary instance (and replicated to other replicas). For MySQL, anything after the first `@` (if present) will be used as the user's host. Set PASSWORD to null if you want to get an autogenerated password. The user types available are: 'BUILT_IN', 'CLOUD_IAM_USER' or 'CLOUD_IAM_SERVICE_ACCOUNT'."
  type = map(object({
    password         = optional(string)
    type             = optional(string)
    access_to_db     = optional(list(string))
    override_special = optional(string, "-_.")
  }))
  default = null
}

variable "iam_users" {
  description = "List of IAM users to create with their types and emails"
  type = list(object({
    email = string
    type  = string
  }))
  validation {
    condition = alltrue([
      for user in var.iam_users :
      contains(["CLOUD_IAM_USER", "CLOUD_IAM_SERVICE_ACCOUNT", "CLOUD_IAM_GROUP",
      "CLOUD_IAM_GROUP_USER", "CLOUD_IAM_GROUP_SERVICE_ACCOUNT"], user.type)
    ])
    error_message = "Valid types are: CLOUD_IAM_USER, CLOUD_IAM_SERVICE_ACCOUNT, CLOUD_IAM_GROUP, CLOUD_IAM_GROUP_USER, CLOUD_IAM_GROUP_SERVICE_ACCOUNT."
  }
  default = []
}

variable "maintenance_window" {
  description = "Backup settings for primary instance. Will be automatically enabled if using MySQL with one or more replicas."
  type = object({
    day          = string
    hour         = string
    update_track = string
  })
  default = {
    day          = "6"
    hour         = "0"
    update_track = "stable"
  }
}

variable "insights_configuration" {
  description = "Enable Query insights"
  type = object({
    enabled                 = bool
    query_string_length     = number
    record_application_tags = bool
    record_client_address   = bool
    query_plans_per_minute  = number
  })
  default = {
    enabled                 = false
    query_string_length     = 1024
    record_application_tags = false
    record_client_address   = false
    query_plans_per_minute  = 5
  }

}
variable "enable_private_path_for_google_cloud_services" {
  description = "(Optional) Whether Google Cloud services such as BigQuery are allowed to access data in this Cloud SQL instance over a private IP connection. SQLSERVER database type is not supported. Default: false"
  type        = bool
  default     = false
}

variable "ssl" {
  description = "Setting to enable SSL, set config and certificates."
  type = object({
    client_certificates = optional(list(string))
    # More details @ https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#ssl_mode
    mode = optional(string)
  })
  default  = {}
  nullable = false
  validation {
    condition     = var.ssl.mode == null || var.ssl.mode == "ALLOW_UNENCRYPTED_AND_ENCRYPTED" || var.ssl.mode == "ENCRYPTED_ONLY" || var.ssl.mode == "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
    error_message = "The variable mode can be ALLOW_UNENCRYPTED_AND_ENCRYPTED, ENCRYPTED_ONLY for all, or TRUSTED_CLIENT_CERTIFICATE_REQUIRED for PostgreSQL or MySQL."
  }
}

variable "shared_vpc_project" {
  description = "Shared VPC projec id"
  type = string
  default = null
}
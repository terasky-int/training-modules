

variable "region" {
  description = "The region of the subnetwork."
  type        = string
}

variable "members_by_subnetwork_and_role" {
  description = "A map of objects, each defining a subnetwork, region, role, and member to grant IAM access."
  type = map(object({
    subnetwork = string
    region     = string
    role       = string
    member     = string
  }))
  default = {} # Make it optional if you only want to use shared VPC sometimes
}

variable "project" {
  description = "The ID of the project for the subnetwork IAM resources. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "host_project" {
  description = "The ID of the host project for Shared VPC."
  type        = string
}

variable "service_projects" {
  description = "A list of service project IDs to attach to the host project."
  type        = list(string)
  default     = [] # Make it optional
}

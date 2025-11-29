variable "project" {
  description = "The project ID to host the database in."
  type        = string
}

variable "region" {
  description = "The region to host the database in."
  type        = string
}


variable "network_name" {
  description = "Network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnetwork name"
  type        = string
}

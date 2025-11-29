terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.49.1"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  batching {
    enable_batching = "false"
  }
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.49.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.49.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30.0"
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

data "google_client_config" "provider" {}
provider "kubernetes" {
  host = format("https://%s", google_container_cluster.cluster.endpoint)

  client_certificate     = base64decode(google_container_cluster.cluster.master_auth[0].client_certificate)
  client_key             = base64decode(google_container_cluster.cluster.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.provider.access_token
}

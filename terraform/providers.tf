# =============================================================================
# Terraform Providers Configuration
# Multi-tier WordPress Application on GKE
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Uncomment to use remote backend (recommended for team collaboration)
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "wordpress-gke/state"
  # }
}

# Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Google Beta Provider (for beta features)
provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Kubernetes Provider - configured after GKE cluster creation
provider "kubernetes" {
  host                   = "https://${module.gke.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
}

# Get current client configuration
data "google_client_config" "default" {}


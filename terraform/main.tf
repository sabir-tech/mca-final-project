# =============================================================================
# Main Terraform Configuration
# Multi-tier WordPress Application on GKE
# Author: Mohd Sabir
# =============================================================================

# -----------------------------------------------------------------------------
# Local Variables
# -----------------------------------------------------------------------------

locals {
  # Common labels for all resources
  common_labels = merge(var.labels, {
    environment = var.environment
    project     = "mca-final-project"
  })

  # Resource naming convention
  name_prefix = "${var.environment}-wordpress"
}

# -----------------------------------------------------------------------------
# VPC Module - Network Infrastructure
# -----------------------------------------------------------------------------

module "vpc" {
  source = "./modules/vpc"

  project_id    = var.project_id
  region        = var.region
  vpc_name      = "${local.name_prefix}-vpc"
  subnet_cidr   = var.subnet_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr
  labels        = local.common_labels
}

# -----------------------------------------------------------------------------
# IAM Module - Service Accounts and Roles
# -----------------------------------------------------------------------------

module "iam" {
  source = "./modules/iam"

  project_id  = var.project_id
  name_prefix = local.name_prefix
}

# -----------------------------------------------------------------------------
# GKE Module - Kubernetes Cluster
# -----------------------------------------------------------------------------

module "gke" {
  source = "./modules/gke"

  project_id              = var.project_id
  region                  = var.region
  zone                    = var.zone
  cluster_name            = "${local.name_prefix}-cluster"
  kubernetes_version      = var.kubernetes_version
  vpc_name                = module.vpc.vpc_name
  subnet_name             = module.vpc.subnet_name
  pods_range_name         = module.vpc.pods_range_name
  services_range_name     = module.vpc.services_range_name
  node_count              = var.node_count
  node_machine_type       = var.node_machine_type
  node_disk_size_gb       = var.node_disk_size_gb
  node_disk_type          = var.node_disk_type
  service_account_email   = module.iam.gke_service_account_email
  enable_autopilot        = var.enable_autopilot
  labels                  = local.common_labels

  depends_on = [module.vpc, module.iam]
}

# -----------------------------------------------------------------------------
# Workload Identity Binding
# Must be created AFTER GKE cluster because the identity pool is created with GKE
# -----------------------------------------------------------------------------

resource "google_service_account_iam_member" "wordpress_workload_identity" {
  service_account_id = module.iam.wordpress_service_account_name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[wordpress/wordpress-sa]"

  depends_on = [module.gke]
}


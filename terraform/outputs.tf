# =============================================================================
# Terraform Outputs
# Multi-tier WordPress Application on GKE
# =============================================================================

# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------

output "vpc_name" {
  description = "The name of the VPC network"
  value       = module.vpc.vpc_name
}

output "vpc_self_link" {
  description = "The self-link of the VPC network"
  value       = module.vpc.vpc_self_link
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = module.vpc.subnet_name
}

output "subnet_cidr" {
  description = "The CIDR range of the subnet"
  value       = module.vpc.subnet_cidr
}

# -----------------------------------------------------------------------------
# GKE Outputs
# -----------------------------------------------------------------------------

output "cluster_name" {
  description = "The name of the GK cluster"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The CA certificate of the GKE cluster"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "The location of the GKE cluster"
  value       = module.gke.cluster_location
}

# -----------------------------------------------------------------------------
# IAM Outputs
# -----------------------------------------------------------------------------

output "gke_service_account_email" {
  description = "The email of the GKE service account"
  value       = module.iam.gke_service_account_email
}

# -----------------------------------------------------------------------------
# kubectl Configuration Command
# -----------------------------------------------------------------------------

output "kubectl_config_command" {
  description = "Command to configure kubectl for the cluster"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --zone ${var.zone} --project ${var.project_id}"
}

# -----------------------------------------------------------------------------
# Project Information
# -----------------------------------------------------------------------------

output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

output "environment" {
  description = "The deployment environment"
  value       = var.environment
}


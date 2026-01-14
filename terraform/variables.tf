# =============================================================================
# Terraform Variables
# Multi-tier WordPress Application on GKE
# =============================================================================

# -----------------------------------------------------------------------------
# Project Configuration
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for zonal resources"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "wordpress-vpc"
}

variable "subnet_cidr" {
  description = "CIDR range for the main subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE pods"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services"
  type        = string
  default     = "10.2.0.0/20"
}

# -----------------------------------------------------------------------------
# GKE Cluster Configuration
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "wordpress-gke-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the GKE cluster"
  type        = string
  default     = "latest"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10 for free tier optimization."
  }
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_disk_size_gb" {
  description = "Disk size in GB for GKE nodes"
  type        = number
  default     = 50
}

variable "node_disk_type" {
  description = "Disk type for GKE nodes"
  type        = string
  default     = "pd-standard"
}

variable "enable_autopilot" {
  description = "Enable GKE Autopilot mode (managed node pools)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Application Configuration
# -----------------------------------------------------------------------------

variable "wordpress_namespace" {
  description = "Kubernetes namespace for WordPress application"
  type        = string
  default     = "wordpress"
}

variable "mysql_storage_size" {
  description = "Storage size for MySQL persistent volume"
  type        = string
  default     = "10Gi"
}

variable "wordpress_storage_size" {
  description = "Storage size for WordPress persistent volume"
  type        = string
  default     = "10Gi"
}

# -----------------------------------------------------------------------------
# Tags and Labels
# -----------------------------------------------------------------------------

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    project     = "wordpress-gke"
    managed-by  = "terraform"
    environment = "dev"
  }
}


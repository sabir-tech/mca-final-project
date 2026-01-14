# =============================================================================
# GKE Module Variables
# =============================================================================

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "zone" {
  description = "The GCP zone"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "latest"
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary range for pods"
  type        = string
}

variable "services_range_name" {
  description = "Name of the secondary range for services"
  type        = string
}

variable "node_count" {
  description = "Number of nodes per zone"
  type        = number
  default     = 2
}

variable "node_machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_disk_size_gb" {
  description = "Disk size for nodes in GB"
  type        = number
  default     = 50
}

variable "node_disk_type" {
  description = "Disk type for nodes"
  type        = string
  default     = "pd-standard"
}

variable "service_account_email" {
  description = "Service account email for nodes"
  type        = string
}

variable "enable_autopilot" {
  description = "Enable Autopilot mode"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels for resources"
  type        = map(string)
  default     = {}
}


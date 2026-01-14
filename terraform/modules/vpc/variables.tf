# =============================================================================
# VPC Module Variables
# =============================================================================

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
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

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}


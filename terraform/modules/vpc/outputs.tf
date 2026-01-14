# =============================================================================
# VPC Module Outputs
# =============================================================================

output "vpc_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "vpc_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_self_link" {
  description = "The self-link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_self_link" {
  description = "The self-link of the subnet"
  value       = google_compute_subnetwork.subnet.self_link
}

output "subnet_cidr" {
  description = "The CIDR range of the subnet"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

output "pods_range_name" {
  description = "The name of the secondary range for pods"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
}

output "services_range_name" {
  description = "The name of the secondary range for services"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
}

output "router_name" {
  description = "The name of the Cloud Router"
  value       = google_compute_router.router.name
}

output "nat_name" {
  description = "The name of the Cloud NAT"
  value       = google_compute_router_nat.nat.name
}


# =============================================================================
# IAM Module Outputs
# =============================================================================

output "gke_service_account_email" {
  description = "The email of the GKE node service account"
  value       = google_service_account.gke_node.email
}

output "gke_service_account_name" {
  description = "The name of the GKE node service account"
  value       = google_service_account.gke_node.name
}

output "wordpress_service_account_email" {
  description = "The email of the WordPress workload service account"
  value       = google_service_account.wordpress_workload.email
}

output "wordpress_service_account_name" {
  description = "The name of the WordPress workload service account"
  value       = google_service_account.wordpress_workload.name
}


# =============================================================================
# IAM Module - Service Accounts and Roles
# Multi-tier WordPress Application on GKE
# =============================================================================

# -----------------------------------------------------------------------------
# GKE Node Service Account
# -----------------------------------------------------------------------------

resource "google_service_account" "gke_node" {
  account_id   = "${var.name_prefix}-gke-node-sa"
  display_name = "GKE Node Service Account for ${var.name_prefix}"
  project      = var.project_id
  description  = "Service account for GKE nodes to access GCP resources"
}

# -----------------------------------------------------------------------------
# IAM Roles for GKE Node Service Account
# -----------------------------------------------------------------------------

# Logging Writer - allows nodes to write logs to Cloud Logging
resource "google_project_iam_member" "gke_node_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

# Monitoring Metric Writer - allows nodes to write metrics
resource "google_project_iam_member" "gke_node_monitoring_metric" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

# Monitoring Viewer - allows nodes to read monitoring data
resource "google_project_iam_member" "gke_node_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

# Storage Object Viewer - allows pulling container images from GCR
resource "google_project_iam_member" "gke_node_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

# Artifact Registry Reader - allows pulling images from Artifact Registry
resource "google_project_iam_member" "gke_node_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

# Resource Metadata Writer - allows nodes to report resource metadata
resource "google_project_iam_member" "gke_node_resource_metadata" {
  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

# -----------------------------------------------------------------------------
# Workload Identity Configuration (Optional but recommended)
# -----------------------------------------------------------------------------

# Service account for WordPress workload
resource "google_service_account" "wordpress_workload" {
  account_id   = "${var.name_prefix}-wordpress-sa"
  display_name = "WordPress Workload Service Account"
  project      = var.project_id
  description  = "Service account for WordPress pods using Workload Identity"
}

# Allow WordPress to access Cloud Storage (for media uploads if needed)
resource "google_project_iam_member" "wordpress_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.wordpress_workload.email}"
}

# NOTE: Workload Identity binding is created in main.tf AFTER the GKE cluster
# because the identity pool (project_id.svc.id.goog) only exists after GKE is created


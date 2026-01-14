# =============================================================================
# GKE Module - Google Kubernetes Engine Cluster
# Multi-tier WordPress Application on GKE
# =============================================================================

# -----------------------------------------------------------------------------
# GKE Cluster
# -----------------------------------------------------------------------------

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  project  = var.project_id
  # Use zone instead of region to reduce resource usage (free tier friendly)
  # Regional clusters create resources in 3 zones which requires more quota
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Network configuration
  network    = var.vpc_name
  subnetwork = var.subnet_name

  # IP allocation policy for VPC-native cluster
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Cluster networking
  networking_mode = "VPC_NATIVE"

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # Master authorized networks
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks (for development only)"
    }
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Release channel for automatic upgrades
  release_channel {
    channel = "REGULAR"
  }

  # Cluster add-ons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  # Network policy
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  # Logging and monitoring
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  # Maintenance window (Sunday 2-6 AM)
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  # Resource labels
  resource_labels = var.labels

  # Deletion protection (set to false for dev, true for prod)
  deletion_protection = false

  # Timeouts
  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}

# -----------------------------------------------------------------------------
# Primary Node Pool
# -----------------------------------------------------------------------------

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-primary-pool"
  project    = var.project_id
  location   = var.zone  # Match the cluster's zonal location
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  # Node configuration
  node_config {
    preemptible  = true  # Cost savings for dev/test (set to false for prod)
    machine_type = var.node_machine_type

    disk_size_gb = var.node_disk_size_gb
    disk_type    = var.node_disk_type

    # Google recommends custom service accounts with minimal permissions
    service_account = var.service_account_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Labels
    labels = merge(var.labels, {
      pool = "primary"
    })

    # Tags for firewall rules
    tags = ["gke-node", "${var.cluster_name}-node"]

    # Workload metadata configuration for workload identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Shielded instance configuration
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Metadata
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  # Node management
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Upgrade settings
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  # Timeouts
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}


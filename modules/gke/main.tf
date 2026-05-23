# modules/gke/main.tf
# GKE Cluster + Node Pool — equivalent to AWS EKS + Managed Node Group

resource "google_container_cluster" "main" {
  name     = "${var.project_name}-${var.environment}-cluster"
  project  = var.project_id
  location = var.region

  # Remove default node pool — we manage node pools separately (best practice)
  remove_default_node_pool = true
  initial_node_count       = 1

  # Network configuration
  network    = var.network_id
  subnetwork = var.subnet_id

  # VPC-native networking — pods get IPs from secondary range (not node IPs)
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Private cluster — nodes have no public IPs (equivalent to private subnets in AWS)
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false          # Keep master accessible publicly for demo
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # Restrict who can reach the Kubernetes API server
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.authorized_cidr
      display_name = "Authorized access"
    }
  }

  # Workload Identity — GCP equivalent of AWS IRSA
  # Pods authenticate to GCP services using a Kubernetes Service Account
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Automatic upgrades via release channel
  release_channel {
    channel = var.release_channel
  }

  # Enable logging for system components and workloads
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  # Enable Cloud Monitoring + Managed Prometheus
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  # Schedule maintenance during off-peak hours
  maintenance_policy {
    recurring_window {
      start_time = "2026-01-01T22:00:00Z"
      end_time   = "2026-01-02T02:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }
}

# Managed Node Pool — equivalent to AWS EKS Managed Node Group
resource "google_container_node_pool" "main" {
  name     = "${var.project_name}-${var.environment}-node-pool"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.main.name

  # Horizontal autoscaling
  autoscaling {
    min_node_count = var.node_min_count
    max_node_count = var.node_max_count
  }

  node_config {
    machine_type = var.node_machine_type
    disk_size_gb = 50
    disk_type    = "pd-balanced"

    # Node service account — least privilege
    service_account = var.node_service_account
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    # Workload Identity on nodes — must be set alongside cluster config
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Shielded nodes for extra security
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    tags   = ["gke-node", "http-server", "health-check"]
    labels = {
      environment = var.environment
      managed_by  = "terraform"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Zero-downtime rolling upgrade
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

# modules/iam/main.tf
# GCP Service Accounts — equivalent to AWS IAM Roles for EC2/EKS nodes
# Workload Identity is the GCP equivalent of AWS IRSA

# Service account for GKE nodes — principle of least privilege
resource "google_service_account" "gke_nodes" {
  account_id = "gke-node-sa-${var.environment}"
  display_name = "GKE Node Service Account (${var.environment})"
  project      = var.project_id
  description  = "Used by GKE worker nodes to access GCP services"
}

# Allow nodes to write logs to Cloud Logging
resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# Allow nodes to write metrics to Cloud Monitoring
resource "google_project_iam_member" "metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# Allow nodes to pull images from Artifact Registry
resource "google_project_iam_member" "artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# Workload Identity service account — equivalent to AWS IRSA
# Pods use this SA to securely access GCP services without hardcoded credentials
resource "google_service_account" "workload_identity" {
  account_id   = "${var.project_name}-${var.environment}-wi-sa"
  display_name = "Workload Identity SA (${var.environment})"
  project      = var.project_id
  description  = "GCP SA mapped to Kubernetes SA via Workload Identity (GCP equivalent of IRSA)"
}

# Allow GCS access for the workload identity SA
resource "google_project_iam_member" "gcs_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.workload_identity.email}"
}

# SA for the MCP Broker
resource "google_service_account" "mcp_sa" {
  account_id   = "mcp-broker-sa-${var.environment}"
  display_name = "MCP Broker SA - ${var.project_name}-(${var.environment})"
}

# Bind roles to the Service Account
resource "google_project_iam_member" "mcp_sa_roles" {
  # Use a for_each loop to iterate over the required roles
  for_each = toset([
    "roles/logging.logWriter",
    "roles/storage.objectAdmin",
    "roles/secretmanager.secretAccessor"
  ])

  project = var.project_id
  role = each.key
  member = "serviceAccount:${google_service_account.mcp_sa.email}"
}

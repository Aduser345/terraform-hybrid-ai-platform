# modules/vpc/main.tf
# GCP VPC equivalent to AWS VPC + subnets + NAT Gateway + IGW

# Custom mode VPC — no default subnets created automatically
resource "google_compute_network" "main" {
  name                    = "${var.project_name}-${var.environment}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false   # Custom subnets only
  routing_mode            = "REGIONAL"
}

# Primary subnet — GKE nodes live here
# Secondary ranges used by GKE for pods and services (VPC-native)
resource "google_compute_subnetwork" "gke" {
  name          = "${var.project_name}-${var.environment}-subnet"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.main.id
  ip_cidr_range = var.vpc_cidr

  # Pods secondary range — GKE assigns pod IPs from here
  secondary_ip_range {
    range_name    = "${var.project_name}-${var.environment}-pods"
    ip_cidr_range = var.pods_cidr
  }

  # Services secondary range — ClusterIP services use this
  secondary_ip_range {
    range_name    = "${var.project_name}-${var.environment}-services"
    ip_cidr_range = var.services_cidr
  }

  private_ip_google_access = true  # Allows private access to Google APIs
}

# Cloud Router — required for Cloud NAT
resource "google_compute_router" "main" {
  name    = "${var.project_name}-${var.environment}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.main.id
}

# Cloud NAT — equivalent to AWS NAT Gateway
# Allows GKE nodes (private) to make outbound internet calls
resource "google_compute_router_nat" "main" {
  name                               = "${var.project_name}-${var.environment}-nat"
  project                            = var.project_id
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# modules/firewall/main.tf
# GCP Firewall Rules — equivalent to AWS Security Groups
# GCP uses network-level firewall rules with target tags and priority numbers

# Allow HTTP/HTTPS from internet to load-balancer tagged instances
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.project_name}-${var.environment}-allow-https"
  project = var.project_id
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]   # Only applies to instances with this tag
  priority      = 1000
  direction     = "INGRESS"
  description   = "Allow HTTP/HTTPS from internet to tagged instances"
}

# Allow internal communication within the VPC subnet
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-${var.environment}-allow-internal"
  project = var.project_id
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [var.vpc_cidr]
  priority      = 1000
  direction     = "INGRESS"
  description   = "Allow all internal traffic within VPC"
}

# Allow Google health check probes — required for load balancers
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.project_name}-${var.environment}-allow-health-checks"
  project = var.project_id
  network = var.network_name

  allow {
    protocol = "tcp"
  }

  # Google's fixed health check IP ranges
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["health-check"]
  priority      = 1000
  direction     = "INGRESS"
  description   = "Allow GCP health checks for load balancers"
}

# Allow IAP (Identity-Aware Proxy) SSH — equivalent to AWS SSM Session Manager
# Provides secure SSH without public IPs or open SSH ports to the internet
resource "google_compute_firewall" "allow_iap" {
  name    = "${var.project_name}-${var.environment}-allow-iap"
  project = var.project_id
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]   # IAP's fixed IP range
  target_tags   = ["iap-ssh"]
  priority      = 1000
  direction     = "INGRESS"
  description   = "Allow IAP tunnel SSH — no public IP required"
}

# Allow GKE master to reach node ports (required for webhooks and metrics)
resource "google_compute_firewall" "allow_gke_master" {
  name    = "${var.project_name}-${var.environment}-allow-gke-master"
  project = var.project_id
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["443", "10250", "8443"]
  }

  source_ranges = ["172.16.0.0/28"]   # GKE master CIDR (set in gke module)
  target_tags   = ["gke-node"]
  priority      = 1000
  direction     = "INGRESS"
  description   = "Allow GKE control plane to communicate with nodes"
}

# Deny all other ingress explicitly (low priority — everything else is denied by default)
resource "google_compute_firewall" "deny_all_ingress" {
  name    = "${var.project_name}-${var.environment}-deny-all-ingress"
  project = var.project_id
  network = var.network_name

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  priority      = 65534
  direction     = "INGRESS"
  description   = "Deny all other ingress traffic — default deny"
}

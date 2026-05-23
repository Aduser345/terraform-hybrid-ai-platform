output "network_name"        { value = google_compute_network.main.name }
output "network_id"          { value = google_compute_network.main.id }
output "subnet_id"           { value = google_compute_subnetwork.gke.id }
output "subnet_name"         { value = google_compute_subnetwork.gke.name }
output "pods_range_name"     { value = google_compute_subnetwork.gke.secondary_ip_range[0].range_name }
output "services_range_name" { value = google_compute_subnetwork.gke.secondary_ip_range[1].range_name }

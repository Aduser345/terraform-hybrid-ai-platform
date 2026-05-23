output "http_firewall_name"     { value = google_compute_firewall.allow_http_https.name }
output "internal_firewall_name" { value = google_compute_firewall.allow_internal.name }

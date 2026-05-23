output "node_service_account_email" {
  value = google_service_account.gke_nodes.email
}
output "workload_identity_sa_email" {
  value = google_service_account.workload_identity.email
}

output "mcp_sa_email" {
  description = "Email id for the MCP SA"
  value = google_service_account.mcp_sa.email
}
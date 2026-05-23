output "broker_uri" {
  description = "The public URI of the MCP Broker"
  value       = google_cloud_run_v2_service.mcp_broker.uri
}
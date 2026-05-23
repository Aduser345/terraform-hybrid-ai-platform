# outputs.tf
# Exposes key values after apply

output "network_name" {
  description = "Name of the VPC network"
  value       = module.vpc.network_name
}

output "subnet_id" {
  description = "ID of the GKE subnet"
  value       = module.vpc.subnet_id
}

output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "GKE master endpoint"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "node_service_account" {
  description = "Service account used by GKE nodes"
  value       = module.iam.node_service_account_email
}

output "mcp_broker_url" {
  description = "The endpoint URL for the Cloud Run MCP Server"
  value       = module.cloud_run_mcp.broker_uri
}
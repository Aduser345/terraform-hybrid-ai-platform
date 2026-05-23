output "secret_ids" {
  description = "The IDs of the generated secrets"
  # Use a for loop to output a map of the secret names to their full GCP resource IDs
  value = { for k, v in google_secret_manager_secret.mcp_secrets : k => v.id }
}
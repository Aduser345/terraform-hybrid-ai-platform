resource "google_secret_manager_secret" "mcp_secrets" {
  # 1. Add your for_each loop here, pointing to the secret_names variable
  for_each = var.secret_names
  # 2. Define the secret_id (use interpolation for environment uniqueness)
  secret_id = "${each.key}-${var.environment}"
  project   = var.project_id

  # 3. The replication block is required by GCP to know where to store the secret physically
  replication {
    auto {}
  }
}
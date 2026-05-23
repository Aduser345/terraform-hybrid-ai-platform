resource "google_storage_bucket" "mcp_context_bucket" {
  # 1. Define the core attributes
  name     = "${var.project_name}-${var.environment}-mcp-context"
  location = var.region
  project  = var.project_id

  # 2. Enforce modern security controls
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  # 3. Add a versioning block (Optional but highly recommended)
  versioning {
    enabled = true
  }
}
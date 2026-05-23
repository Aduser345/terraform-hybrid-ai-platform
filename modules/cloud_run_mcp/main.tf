resource "google_cloud_run_v2_service" "mcp_broker" {
  # 1. Name the service and set the location
  name     = "mcp-broker-${var.environment}"
  location = var.region
  project  = var.project_id
  
  # 2. Block direct public internet access
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    # 3. Attach the secure Service Account
    service_account = var.mcp_sa_email

    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Placeholder image for now

      # 4. Pass the Bucket Name as an environment variable
      env {
        name  = "CONTEXT_BUCKET"
        value = var.context_bucket_name
      }

      # 5. Mount the Secret Manager secrets dynamically
      dynamic "env" {
        for_each = var.secret_ids
        content {
          name = upper(replace(env.key, "-", "_")) # Formats 'openai-key' to 'OPENAI_KEY'
          value_source {
            secret_key_ref {
              secret  = env.value
              version = "latest"
            }
          }
        }
      }
    }
  }
}
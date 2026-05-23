variable "project_id" { 
    type = string
    description = "GCP Project ID for the GCP Secrets manager module"
}
variable "environment" { 
    type = string
    description = "GCP Environment for the GCP Secrets manager module"
}
variable "region" { 
    type = string
    description = "GCP Region for the GCS module"
}
# Inputs from other modules
variable "mcp_sa_email" {
  description = "The Service Account email to attach to the server"
  type        = string
}

variable "context_bucket_name" {
  description = "The GCS bucket for AI context"
  type        = string
}

variable "secret_ids" {
  description = "Map of secret names to their GCP resource IDs"
  type        = map(string)
}

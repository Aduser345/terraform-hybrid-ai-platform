output "bucket_name" {
  # Define description and value here
  value = google_storage_bucket.mcp_context_bucket.name
  description = "GCS Bucket Name"
}
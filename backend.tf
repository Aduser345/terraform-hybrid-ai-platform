# backend.tf
# Remote state stored in Google Cloud Storage (GCS)
# Replace <your-gcs-bucket> before applying

# Uncomment below block and replace bucket name before applying:
# terraform {
#   backend "gcs" {
#     bucket = "<your-gcs-bucket>"
#     prefix = "gke-infra/terraform.tfstate"
#   }
# }

variable "project_id" { 
    type = string
    description = "GCP Project ID for the GCP Secrets manager module"
}
variable "environment" { 
    type = string
    description = "GCP Environment for the GCP Secrets manager module"
}
variable "secret_names" { 
    type = set(string)
    description = "Secret Names for the GCP Secrets manager"
}
# variables.tf
# All input variables used across the project

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region to deploy resources into"
  type        = string
  default     = "asia-south1"
}

variable "environment" {
  description = "Deployment environment: dev, staging, prod"
  type        = string
}

variable "project_name" {
  description = "Used for naming and labelling resources"
  type        = string
  default     = "gke-infra"
}

variable "vpc_cidr" {
  description = "Primary CIDR range for the VPC subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE pods"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services"
  type        = string
  default     = "10.2.0.0/20"
}

variable "gke_cluster_version" {
  description = "GKE release channel"
  type        = string
  default     = "REGULAR"
}

variable "node_machine_type" {
  description = "GCE machine type for GKE nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "node_min_count" {
  description = "Minimum nodes per zone in autoscaling"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum nodes per zone in autoscaling"
  type        = number
  default     = 4
}

variable "authorized_cidr" {
  description = "CIDR allowed to reach GKE master endpoint"
  type        = string
  default     = "0.0.0.0/0"
}

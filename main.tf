# main.tf
# Root module — wires VPC, Firewall, IAM, GKE, and MCP modules together

module "vpc" {
  source        = "./modules/vpc"
  project_id    = var.project_id
  project_name  = var.project_name
  environment   = var.environment
  region        = var.region
  vpc_cidr      = var.vpc_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr
}

module "firewall" {
  source       = "./modules/firewall"
  project_id   = var.project_id
  project_name = var.project_name
  environment  = var.environment
  network_name = module.vpc.network_name
  vpc_cidr     = var.vpc_cidr
}

# Unified IAM Module (Handles GKE nodes AND Cloud Run broker)
module "iam" {
  source       = "./modules/iam"
  project_id   = var.project_id
  project_name = var.project_name
  environment  = var.environment
}

module "gke" {
  source               = "./modules/gke"
  project_id           = var.project_id
  project_name         = var.project_name
  environment          = var.environment
  region               = var.region
  network_id           = module.vpc.network_id
  subnet_id            = module.vpc.subnet_id
  pods_range_name      = module.vpc.pods_range_name
  services_range_name  = module.vpc.services_range_name
  node_service_account = module.iam.node_service_account_email
  release_channel      = var.gke_cluster_version
  node_machine_type    = var.node_machine_type
  node_min_count       = var.node_min_count
  node_max_count       = var.node_max_count
  authorized_cidr      = var.authorized_cidr
}

module "storage_context" {
  source       = "./modules/storage_context"
  project_id   = var.project_id
  project_name = var.project_name
  environment  = var.environment
  region       = var.region
}

module "secret_manager" {
  source       = "./modules/secrets_manager"
  project_id   = var.project_id
  environment  = var.environment
  secret_names = [
    "anthropic-api-key",
    "github-token"
  ]
}

module "cloud_run_mcp" {
  source              = "./modules/cloud_run_mcp"
  project_id          = var.project_id
  region              = var.region
  environment         = var.environment
  mcp_sa_email        = module.iam.mcp_sa_email
  context_bucket_name = module.storage_context.bucket_name
  secret_ids          = module.secret_manager.secret_ids
}
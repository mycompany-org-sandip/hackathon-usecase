terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}



provider "google" {
  project = var.project_id
  region  = var.region
}

## Removed default service account lookup to avoid IAM permission issues

# -------------------------------

# Network Module

# -------------------------------

module "network" {
  source = "../../modules/network"

  project_id              = var.project_id
  region                  = var.region
  environment             = var.environment
  network_name            = "${var.environment}-vpc"
  auto_create_subnetworks = false

  public_subnet_names       = var.public_subnet_names
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks

  private_subnet_names       = var.private_subnet_names
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks

  firewall_ssh_source_ranges = var.firewall_ssh_source_ranges
  allow_http                 = var.allow_http
  allow_https                = var.allow_https
}

# -------------------------------

# IAM Module

# -------------------------------

module "iam" {
  source     = "../../modules/iam"
  project_id = var.project_id

  service_accounts = {
    app-runner = {
      display_name = "Staging App Runner"
      roles        = ["roles/container.admin", "roles/logging.logWriter"]
    }
  }
}

# -------------------------------

# Secret Manager Module

# -------------------------------

module "secret_manager" {
  source     = "../../modules/secret_manager"
  project_id = var.project_id

  secrets = [
    "api-key",
    "db-connection"
  ]
}

# -------------------------------

# Artifact Registry Module

# -------------------------------

module "artifact_registry" {
  source      = "../../modules/artifact_registry"
  project_id  = var.project_id
  environment = var.environment
  repo_name   = var.repo_name
  artifact_region = var.region
}
# -------------------------------

module "gke" {
  count        = var.enable_gke ? 1 : 0
  source       = "../../modules/gke"
  project_id   = var.project_id
  cluster_name = var.cluster_name
  region       = var.region

  network              = module.network.vpc_self_link
  subnetwork           = module.network.private_subnet_self_links[0]
  node_service_account = var.app_runner_sa
}

# -------------------------------



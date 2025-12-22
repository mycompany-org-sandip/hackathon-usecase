terraform {
  backend "gcs" {}
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
    app-runner-prod = {
      display_name = "Prod App Runner"
      roles        = [
        "roles/container.admin",
        "roles/logging.logWriter"
      ]
    }
    gke-nodes-prod = {
      display_name = "Prod GKE Nodes"
      roles        = [
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/artifactregistry.reader"
      ]
    }
  }
}

# -------------------------------

# Secret Manager Module

# -------------------------------

module "secret_manager" {
  source        = "../../modules/secret_manager"
  project_id    = var.project_id
  environment   = var.environment
  app_runner_sa = var.app_runner_sa

  secrets = {
    "db-connection" = {}
    "api-key"       = {}
    "another-secret" = {}
  }

  # Explicitly set access bindings for clarity in validation/CI
  access_bindings = {}
}



# -------------------------------

# Artifact Registry Module

# -------------------------------

module "artifact_registry" {
  source          = "../../modules/artifact_registry"
  project_id      = var.project_id
  environment     = var.environment
  repo_name       = var.repo_name
  artifact_region = var.artifact_region
}
# -------------------------------

# GKE Module

# -------------------------------
module "gke" {
  source = "../../modules/gke"

  project_id           = var.project_id
  region               = var.region
  cluster_name         = var.cluster_name
  network              = module.network.vpc_self_link
  subnetwork           = module.network.private_subnet_self_links[0]

  node_service_account = module.iam.service_account_emails["gke-nodes-prod"]
  deletion_protection  = var.deletion_protection

  depends_on = [
    module.iam,
    module.network
  ]
}


# -------------------------------


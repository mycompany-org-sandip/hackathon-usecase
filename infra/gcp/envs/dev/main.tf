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

  public_subnet_names        = var.public_subnet_names
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks

  private_subnet_names        = var.private_subnet_names
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
      display_name = "Dev App Runner"
      roles        = [
        "roles/container.admin",
        "roles/logging.logWriter"
      ]
    }
  }
}

# -------------------------------
# Secret Manager Module
# -------------------------------
module "secrets" {
  source     = "../../modules/secret_manager"
  project_id = var.project_id

  secrets = {
    "db-connection" = {
      replication   = { automatic = true }
      initial_value = ""
      labels        = { env = var.environment }
    }
    "api-key" = {
      replication   = { automatic = true }
      initial_value = ""
      labels        = { env = var.environment }
    }
  }

  access_bindings = {
    "db-connection" = [
      "serviceAccount:${module.iam.service_account_emails["app-runner"]}"
    ]
    "api-key" = [
      "serviceAccount:${module.iam.service_account_emails["app-runner"]}"
    ]
  }
}

# -------------------------------
# Artifact Registry
# -------------------------------
module "artifact_registry" {
  source      = "../../modules/artifact_registry"
  project_id  = var.project_id
  environment = var.environment
  repo_name   = var.repo_name
  region      = var.region
}

# -------------------------------
# GKE Cluster
# -------------------------------
module "gke" {
  source       = "../../modules/gke"
  project_id   = var.project_id
  cluster_name = var.cluster_name
  region       = var.region

  network    = module.network.vpc_self_link
  subnetwork = module.network.private_subnet_self_links[0]
}

# -------------------------------       
# Outputs
# -------------------------------
#output "network_info" {




#







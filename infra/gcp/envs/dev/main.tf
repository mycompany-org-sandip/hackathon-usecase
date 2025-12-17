terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }
}



provider "google" {
  project = var.project_id
  region  = var.region
}

# -------------------------------
# Required APIs (ensure default SAs and services exist)
# -------------------------------
resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iamcredentials" {
  project            = var.project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  project            = var.project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "serviceusage" {
  project            = var.project_id
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

resource "time_sleep" "wait_for_compute_sa" {
  depends_on      = [google_project_service.compute, google_project_service.iam, google_project_service.container]
  create_duration = "180s"
}

# -------------------------------
# Network Module
# -------------------------------
module "network" {
  source = "../../modules/network"

  project_id              = var.project_id
  region                  = var.region
  environment             = var.environment
  network_name            = "vpc-dev"
  auto_create_subnetworks = false

  public_subnet_names       = var.public_subnet_names
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks

  private_subnet_names       = var.private_subnet_names
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks

  firewall_ssh_source_ranges = var.firewall_ssh_source_ranges
  allow_http                 = var.allow_http
  allow_https                = var.allow_https
  nat_include_subnet_names   = ["dev-private-subnet-2"]
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
      roles = [
        "roles/container.admin",
        "roles/logging.logWriter"
      ]
    }
  }
}

# -------------------------------
# Secret Manager Module
# -------------------------------
module "secret_manager" {
  source     = "../../modules/secret_manager"
  project_id = var.project_id

  secrets = {
    "api-key"       = "api-key"
    "db-connection" = "db-connection"
  }

  access_bindings = {
    "api-key" = [
      "serviceAccount:${var.app_runner_sa}"
    ]
    "db-connection" = [
      "serviceAccount:${var.app_runner_sa}"
    ]
  }
}


# -------------------------------
# Artifact Registry
# -------------------------------
module "artifact_registry" {
  source          = "../../modules/artifact_registry"
  project_id      = var.project_id
  environment     = var.environment
  repo_name       = var.repo_name
  artifact_region = var.artifact_region
}

# -------------------------------
# GKE Cluster
# -------------------------------


module "gke" {
  source = "../../modules/gke"

  project_id                = var.project_id
  region                    = var.region
  cluster_name              = var.cluster_name
  network                   = module.network.vpc_self_link
  subnetwork                = module.network.private_subnet_self_links[0]
  node_pool_service_account = var.node_service_account
}




# -------------------------------
# End of configuration
# -------------------------------








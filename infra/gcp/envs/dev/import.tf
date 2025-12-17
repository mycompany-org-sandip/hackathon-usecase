# Artifact Registry
import {
  to = module.artifact_registry.google_artifact_registry_repository.repo[0]
  id = "projects/massive-sandbox-477717-k3/locations/us-central1/repositories/dev-docker-repo"
}

# VPC
import {
  to = module.network.google_compute_network.vpc
  id = "projects/massive-sandbox-477717-k3/global/networks/dev-vpc-dev"
}

# IAM Service Account
import {
  to = module.iam.google_service_account.accounts["app-runner"]
  id = "projects/massive-sandbox-477717-k3/serviceAccounts/app-runner@massive-sandbox-477717-k3.iam.gserviceaccount.com"
}

# Secret Manager - db connection
import {
  to = module.secret_manager.google_secret_manager_secret.secrets["db-connection"]
  id = "projects/661961012629/secrets/db-connection"
}

# Secret Manager - api key
import {
  to = module.secret_manager.google_secret_manager_secret.secrets["api-key"]
  id = "projects/661961012629/secrets/api-key"
}

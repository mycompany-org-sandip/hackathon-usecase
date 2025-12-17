# Project configuration
project_id      = "massive-sandbox-477717-k3"
environment     = "dev"
cluster_name    = "dev-cluster"
repo_name       = "dev-docker"
artifact_region = "us-central1"

# Network configuration
cidr_block = 10
# Keep the existing subnet to avoid destroy, add the second subnet
private_subnet_names       = ["dev-subnet", "dev-private-subnet-2"]
private_subnet_cidr_blocks = ["10.10.0.0/20", "10.0.2.0/24"]

# Service account
app_runner_sa        = "app-runner@massive-sandbox-477717-k3.iam.gserviceaccount.com"
node_service_account = "gke-nodes@massive-sandbox-477717-k3.iam.gserviceaccount.com"


project_id  = "massive-sandbox-477717-k3"
region      = "us-central1"
environment = "prod"

repo_name    = "prod-docker"
cluster_name = "prod-gke"

private_subnet_names       = ["prod-subnet"]
private_subnet_cidr_blocks = ["10.30.0.0/20"]

public_subnet_names       = []
public_subnet_cidr_blocks = []

firewall_ssh_source_ranges = ["0.0.0.0/0"]
allow_http                 = true
allow_https                = true

# Service accounts
# Used by applications to access secrets
app_runner_sa        = "app-runner@massive-sandbox-477717-k3.iam.gserviceaccount.com"
# Used by GKE nodes; using the same SA for now
node_service_account = "app-runner@massive-sandbox-477717-k3.iam.gserviceaccount.com"

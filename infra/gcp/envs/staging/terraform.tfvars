project_id  = "massive-sandbox-477717-k3"
region      = "us-central1"
environment = "staging"

repo_name    = "stg-docker"
cluster_name = "stg-gke"

private_subnet_names       = ["stg-subnet"]
private_subnet_cidr_blocks = ["10.20.0.0/20"]

public_subnet_names       = []
public_subnet_cidr_blocks = []

firewall_ssh_source_ranges = ["0.0.0.0/0"]
allow_http                 = true
allow_https                = true

app_runner_sa        = "app-runner-staging@massive-sandbox-477717-k3.iam.gserviceaccount.com"
node_service_account = "gke-nodes-staging@massive-sandbox-477717-k3.iam.gserviceaccount.com"

# Allow cluster destroy when tearing down staging
deletion_protection = false

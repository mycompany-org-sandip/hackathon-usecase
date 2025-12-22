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


app_runner_sa        = "app-runner-prod@massive-sandbox-477717-k3.iam.gserviceaccount.com"
node_service_account = "gke-nodes-prod@massive-sandbox-477717-k3.iam.gserviceaccount.com"

# Allow cluster destroy when tearing down prod
deletion_protection = false

artifact_region = "us-central1"

secrets = {}

access_bindings = {}

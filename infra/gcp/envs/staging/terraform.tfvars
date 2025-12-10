project_id  = "massive-sandbox-477717-k3"
region      = "asia-south1"
environment = "staging"

cluster_name = "staging-gke"
repo_name    = "staging"

cidr_block = 20

private_subnet_names        = ["staging-subnet"]
private_subnet_cidr_blocks = ["10.20.0.0/20"]

public_subnet_names        = []
public_subnet_cidr_blocks = []

firewall_ssh_source_ranges = ["0.0.0.0/0"]

allow_http  = true
allow_https = true

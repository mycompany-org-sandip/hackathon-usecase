# GCP Terraform Infrastructure

This directory provisions Google Cloud resources for multiple environments (`dev`, `staging`, `prod`) using isolated remote state.

## Structure
```
infra/gcp/
  modules/
    network/      # VPC, subnets, firewall, NAT
    iam/          # Service accounts, custom roles
    state/        # (Optional) state bucket creation (run once per env or shared)
  envs/
    dev/
    staging/
    prod/
```
Each environment folder contains its own `backend` configuration pointing to a distinct bucket or prefix.

## Remote State & Locking
Terraform uses the `gcs` backend in `versions.tf`. Example (dev):
```hcl
backend "gcs" {
  bucket = "tf-state-dev-example"
  prefix = "env/dev"
}
```
1 bucket per environment (recommended for strong isolation) OR 1 shared bucket with different prefixes.

Locking: The GCS backend uses object preconditions for locking (implicit). Do not set `disable_locking` unless necessary.

To create buckets, apply the `state` module first (from a bootstrap workspace) or manually create with:
```bash
gcloud storage buckets create gs://tf-state-dev-example --project <PROJECT_ID> --location=US --uniform-bucket-level-access
```
Enable versioning (required for state history):
```bash
gcloud storage buckets update gs://tf-state-dev-example --versioning
```

## Network Module Overview
- VPC without auto subnetworks
- 2 public + 2 private subnets (CIDRs defined per environment)
- Internal firewall rule allowing intra-subnet traffic
- SSH, HTTP, HTTPS firewall rules (tags: `ssh`, `http`, `https`)
- Cloud Router + Cloud NAT for private subnet egress

## IAM Module Overview
- Declares service accounts via a map
- Optional custom project IAM roles

## Customization
Edit `terraform.tfvars` in each environment:
```hcl
project_id = "your-gcp-project-id-dev"
region     = "us-central1"
```
Adjust subnet CIDRs in the `main.tf` of each env as needed.

## Usage
From an environment folder, e.g. `dev`:
```bash
cd infra/gcp/envs/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Destroy (careful in prod):
```bash
terraform destroy -var-file=terraform.tfvars
```

## Workspace Separation (Alternative)
Instead of separate folders you could use Terraform workspaces with variable conditionals, but folder-per-env is simpler for distinct networking and IAM configs. If using workspaces in a single folder:
```hcl
terraform {
  backend "gcs" { bucket = "tf-state-shared" prefix = "workspaces" }
}
```
Then:
```bash
terraform workspace new dev
terraform workspace select dev
```
Variables can read `terraform.workspace` to branch logic—NOT implemented here to keep clarity.

## Adding More Resources
You can add modules for:
- Cloud SQL / AlloyDB (private IP) -> requires additional private service connect
- GKE cluster (attach inside VPC private subnets)
- Cloud Load Balancing (HTTP(S) external) pointing to backend services
- Pub/Sub topics & subscriptions

## Security Hardening Suggestions
- Restrict SSH source ranges
- Add firewall deny rules for unexpected egress
- Use CMEK for state bucket encryption (`google_storage_bucket` + `google_kms_key_ring`)
- Enable VPC Flow Logs (add `enable_flow_logs = true` on subnets)

## Next Steps
1. Replace placeholder project IDs in all `terraform.tfvars`.
2. Create state buckets (or apply `modules/state` separately).
3. Run `terraform init` per environment.
4. Extend modules for additional services as needed.

## Bootstrap State Bucket with Module (Optional)
Example run (dev):
```bash
cd infra/gcp/modules/state
# Create a simple wrapper main.tf referencing module or use inline
```
(Current implementation expects you to call the module from a separate stack if desired.)

## Notes
- GCP subnets are regional; the concept of AZ is abstracted. For multi-zone workloads (e.g., GKE or Compute Engine MIG), ensure region-level subnets and set instance templates to use multiple zones.
- Cloud NAT configuration currently NATs all private subnets.

---
Maintain parity with Azure infra by expanding modules similarly if needed.

# Quick Commands (macOS zsh)

Use these to build locally, push images, provision infra, and deploy.

## 1) Build Locally
```bash
# Patient Service (Node.js)
cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/patient-service
npm install
npm run start

# Application Service (Node.js)
cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/application-service
npm install
npm run start

# Order Service (Java)
cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/order-service
./mvnw clean package -DskipTests || mvn clean package -DskipTests
```

## 2) Registry Choice
### Azure ACR
```bash
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
RESOURCE_GROUP="rg-hackathon-dev"
LOCATION="eastus"
ACR_NAME="hackathonacr$RANDOM"
az group create -n "$RESOURCE_GROUP" -l "$LOCATION"
az acr create -n "$ACR_NAME" -g "$RESOURCE_GROUP" -l "$LOCATION" --sku Standard
az acr login --name "$ACR_NAME"
ACR_SERVER="$(az acr show -n "$ACR_NAME" --query loginServer -o tsv)"
```
### GCP GCR
```bash
gcloud auth login
gcloud config set project <YOUR_GCP_PROJECT_ID>
gcloud auth configure-docker
GCR_SERVER="gcr.io/<YOUR_GCP_PROJECT_ID>"
```

## 3) Docker Build & Push
```bash
VERSION="v0.1.0"

cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/patient-service
docker build -t "$ACR_SERVER/patient-service:$VERSION" . && docker push "$ACR_SERVER/patient-service:$VERSION"
docker build -t "$GCR_SERVER/patient-service:$VERSION" . && docker push "$GCR_SERVER/patient-service:$VERSION"

cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/application-service
docker build -t "$ACR_SERVER/application-service:$VERSION" . && docker push "$ACR_SERVER/application-service:$VERSION"
docker build -t "$GCR_SERVER/application-service:$VERSION" . && docker push "$GCR_SERVER/application-service:$VERSION"

cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/order-service
docker build -t "$ACR_SERVER/order-service:$VERSION" . && docker push "$ACR_SERVER/order-service:$VERSION"
docker build -t "$GCR_SERVER/order-service:$VERSION" . && docker push "$GCR_SERVER/order-service:$VERSION"
```

## 4) Terraform Remote State & Provision (Azure)
```bash
RG_STATE="$RESOURCE_GROUP"
SA_NAME="tfstate$RANDOM"
CONTAINER_NAME="tfstate"
az storage account create -n "$SA_NAME" -g "$RG_STATE" -l "$LOCATION" --sku Standard_LRS
ACCOUNT_KEY="$(az storage account keys list -n "$SA_NAME" -g "$RG_STATE" --query '[0].value' -o tsv)"
az storage container create --name "$CONTAINER_NAME" --account-name "$SA_NAME" --account-key "$ACCOUNT_KEY"

# Edit infra/azure/envs/dev/backend.tfvars accordingly
cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/infra/azure/envs/dev
terraform init -backend-config=backend.tfvars
terraform workspace new dev || true
terraform workspace select dev
terraform fmt -recursive
terraform validate
terraform plan -var-file=variables.tf
terraform apply -var-file=variables.tf -auto-approve
```

## 4b) Terraform Remote State & Provision (GCP)
```bash
# Set project and region
PROJECT_ID="<YOUR_GCP_PROJECT_ID>"
REGION="asia-south1"
gcloud auth login
gcloud config set project "$PROJECT_ID"

# Enable required APIs
gcloud services enable compute.googleapis.com container.googleapis.com iam.googleapis.com secretmanager.googleapis.com

# Create a GCS bucket for Terraform remote state (unique name required)
TF_BUCKET="${PROJECT_ID}-tfstate-$(date +%Y%m%d)"
gsutil mb -l "$REGION" "gs://$TF_BUCKET" || true
gsutil versioning set on "gs://$TF_BUCKET"

# Optional: create separate prefixes per environment
TF_PREFIX_DEV="terraform/dev"
TF_PREFIX_STAGING="terraform/staging"
TF_PREFIX_PROD="terraform/prod"

# Dev environment
cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/infra/gcp/envs/dev
# If using backend config file, update bucket/prefix inside it; else pass via -backend-config
terraform init \
	-backend-config="bucket=$TF_BUCKET" \
	-backend-config="prefix=$TF_PREFIX_DEV"
terraform workspace new dev || true
terraform workspace select dev
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars -auto-approve

# Staging environment
cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/infra/gcp/envs/staging
terraform init \
	-backend-config="bucket=$TF_BUCKET" \
	-backend-config="prefix=$TF_PREFIX_STAGING"
terraform workspace new staging || true
terraform workspace select staging
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars -auto-approve

# Prod environment
cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/infra/gcp/envs/prod
terraform init \
	-backend-config="bucket=$TF_BUCKET" \
	-backend-config="prefix=$TF_PREFIX_PROD"
terraform workspace new prod || true
terraform workspace select prod
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars -auto-approve
```

## 5) AKS Access & ACR Attach
```bash
AKS_RG="<AKS_RESOURCE_GROUP_FROM_TF>"
AKS_NAME="<AKS_NAME_FROM_TF>"
az aks get-credentials -g "$AKS_RG" -n "$AKS_NAME" --overwrite-existing
az aks update -n "$AKS_NAME" -g "$AKS_RG" --attach-acr "$ACR_NAME"
```

## 6) GKE Access & GCR (or Artifact Registry) Attach
```bash
PROJECT_ID="<YOUR_GCP_PROJECT_ID>"
REGION="us-central1"               # match cluster region
CLUSTER_NAME="hackathon-gke"       # or name from terraform if managed there

# Get credentials for existing GKE cluster (already created or via Terraform)
gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$REGION"

# Configure Docker auth for GCR (legacy) and Artifact Registry (recommended)
gcloud auth configure-docker
gcloud auth configure-docker "$REGION-docker.pkg.dev"

# (Optional) Create an Artifact Registry repo if not yet present
REPO_NAME="hackathon-apps"
gcloud artifacts repositories create "$REPO_NAME" \
	--repository-format=docker \
	--location="$REGION" \
	--description="Container images for hackathon" || true

# Tag & push example image to Artifact Registry
AR_SERVER="$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME"
docker tag patient-service:latest "$AR_SERVER/patient-service:latest"
docker push "$AR_SERVER/patient-service:latest"

# If pulling images from a DIFFERENT project, grant Storage Object Viewer to the GKE node service account
# (Skip if images and cluster share the same project.)
SOURCE_IMAGES_PROJECT_ID="<IMAGES_SOURCE_PROJECT>"   # project hosting registry
TARGET_CLUSTER_PROJECT_ID="$PROJECT_ID"              # cluster's project
gcloud projects add-iam-policy-binding "$SOURCE_IMAGES_PROJECT_ID" \
	--member="serviceAccount:service-$TARGET_CLUSTER_PROJECT_ID@containerregistry.iam.gserviceaccount.com" \
	--role="roles/storage.objectViewer"

# Verify access by listing images (GCR) or artifacts (Artifact Registry)
gcloud artifacts docker images list "$AR_SERVER" || true
```

## 7) Helm Deploy
```bash
cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/helm/umbrella
helm dependency update
helm upgrade --install healthcare-umbrella . -n default --create-namespace
kubectl get pods -n default
```

## 8) Key Vault Secrets
```bash
KV_NAME="<KEYVAULT_NAME_FROM_TF>"
az keyvault secret set --vault-name "$KV_NAME" --name "db-connection" --value "<your-connection-string>"
az keyvault secret set --vault-name "$KV_NAME" --name "api-key" --value "<your-api-key>"
kubectl get secretproviderclass -n default
```

## 8b) GCP Secret Manager
```bash
# Set project context
PROJECT_ID="<YOUR_GCP_PROJECT_ID>"
gcloud config set project "$PROJECT_ID"

# Create secrets (automatic replication)
gcloud secrets create db-connection --replication-policy="automatic"
gcloud secrets create api-key --replication-policy="automatic" || true

# Add secret versions (use -n to avoid trailing newline)
echo -n "<your-connection-string>" | gcloud secrets versions add db-connection --data-file=-
echo -n "<your-api-key>" | gcloud secrets versions add api-key --data-file=-

# Grant access: allow GKE workloads to read secrets
# Recommended: Workload Identity + a Kubernetes SA bound to a Google Service Account
# Example grants to a Google Service Account (replace with yours)
GSA_NAME="hackathon-workload"
GSA_EMAIL="$GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com"
gcloud iam service-accounts create "$GSA_NAME" --display-name "Hackathon Workload SA" || true
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
	--member="serviceAccount:$GSA_EMAIL" \
	--role="roles/secretmanager.secretAccessor"

# (Optional) If using default compute engine SA (not recommended), grant accessor
# PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')
# gcloud projects add-iam-policy-binding "$PROJECT_ID" \
#   --member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
#   --role="roles/secretmanager.secretAccessor"

# Access a secret locally for verification
gcloud secrets versions access latest --secret=db-connection
gcloud secrets versions access latest --secret=api-key

# Note: For GKE, prefer Workload Identity and mount secrets via env injection in deployments
# or use third-party CSI drivers. This repo includes Azure Key Vault CSI; for GCP, use native
# Secret Manager with app-level access or add the GCP Secret Manager CSI driver if desired.
```

## 9) Monitoring & Logs
```bash
az monitor log-analytics workspace list -g "$RESOURCE_GROUP"
kubectl logs deployment/application-service -n default
kubectl logs deployment/order-service -n default
kubectl logs deployment/patient-service -n default
```

## 10) GKE (Optional)
```bash
REGION="us-central1"
gcloud container clusters create hackathon-gke --region "$REGION" --num-nodes 3
gcloud container clusters get-credentials hackathon-gke --region "$REGION"
cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase/helm/umbrella
helm dependency update
helm upgrade --install healthcare-umbrella . -n default --create-namespace
```

## 11) GitHub Actions (Summary)
- App CI: `.github/workflows/app-ci.yml` builds Node/Java, logs into Azure, builds and pushes images to ACR with `${{ github.sha }}` tag.
- IaC Terraform: `.github/workflows/iac-terraform.yml` runs fmt/validate/plan on PRs and apply on main; use secrets `AZURE_CREDENTIALS`, `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID`, `ACR_NAME`.

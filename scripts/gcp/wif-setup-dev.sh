#!/usr/bin/env bash
set -euo pipefail

# WIF setup helper for GitHub Actions → GCP (dev env)
# - Ensures Workload Identity Pool and OIDC Provider exist and are ACTIVE
# - Configures attribute mapping and allowed audiences
# - Binds the GitHub repo + branch 'dev' to the target Service Account
# - Optionally writes the provider path to GitHub secret WIF_PROVIDER_DEV
#
# Requirements:
# - gcloud CLI authenticated with owner/editor perms on the project
# - (optional) gh CLI authenticated for secret updates
#
# Usage:
#   chmod +x scripts/gcp/wif-setup-dev.sh
#   scripts/gcp/wif-setup-dev.sh \
#     --project-id massive-sandbox-477717-k3 \
#     --service-account github-terraform-dev@massive-sandbox-477717-k3.iam.gserviceaccount.com \
#     --repo "reddysandip/hackathon-usecase" \
#     --branch dev \
#     --pool github-pool \
#     --provider github-provider \
#     [--set-gh-secret]
#

PROJECT_ID=""
SERVICE_ACCOUNT=""
REPO=""
BRANCH="dev"
POOL="github-pool"
PROVIDER="github-provider"
SET_GH_SECRET=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-id)
      PROJECT_ID="$2"; shift 2;;
    --service-account)
      SERVICE_ACCOUNT="$2"; shift 2;;
    --repo)
      REPO="$2"; shift 2;;
    --branch)
      BRANCH="$2"; shift 2;;
    --pool)
      POOL="$2"; shift 2;;
    --provider)
      PROVIDER="$2"; shift 2;;
    --set-gh-secret)
      SET_GH_SECRET=true; shift 1;;
    -h|--help)
      sed -n '1,60p' "$0"; exit 0;;
    *)
      echo "Unknown argument: $1"; exit 1;;
  esac
done

if [[ -z "$PROJECT_ID" || -z "$SERVICE_ACCOUNT" || -z "$REPO" ]]; then
  echo "Required: --project-id, --service-account, --repo" >&2
  exit 2
fi

if ! command -v gcloud >/dev/null 2>&1; then
  echo "gcloud not found. Install Google Cloud SDK first" >&2
  exit 3
fi

echo "Resolving project number for $PROJECT_ID ..."
PN=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')
if [[ -z "$PN" ]]; then
  echo "Failed to resolve project number for $PROJECT_ID" >&2
  exit 4
fi
echo "Project number: $PN"

# Ensure pool exists
if gcloud iam workload-identity-pools describe "$POOL" \
  --project="$PROJECT_ID" --location=global >/dev/null 2>&1; then
  echo "Pool '$POOL' exists."
else
  echo "Creating pool '$POOL' ..."
  gcloud iam workload-identity-pools create "$POOL" \
    --project="$PROJECT_ID" --location=global \
    --display-name="GitHub OIDC"
fi

# Ensure provider exists with correct mapping/audiences
PROVIDER_PATH="projects/$PN/locations/global/workloadIdentityPools/$POOL/providers/$PROVIDER"
if gcloud iam workload-identity-pools providers describe "$PROVIDER" \
  --project="$PROJECT_ID" --location=global --workload-identity-pool="$POOL" >/dev/null 2>&1; then
  echo "Provider '$PROVIDER' exists in pool '$POOL'. Verifying config..."
  CURRENT_STATE=$(gcloud iam workload-identity-pools providers describe "$PROVIDER" \
    --project="$PROJECT_ID" --location=global --workload-identity-pool="$POOL" \
    --format='value(state)')
  echo "Provider state: $CURRENT_STATE"
  if [[ "$CURRENT_STATE" != "ACTIVE" ]]; then
    echo "Warning: Provider state is $CURRENT_STATE (expected ACTIVE)." >&2
  fi
else
  echo "Creating provider '$PROVIDER' ..."
  gcloud iam workload-identity-pools providers create-oidc "$PROVIDER" \
    --project="$PROJECT_ID" --location=global --workload-identity-pool="$POOL" \
    --display-name="GitHub Actions" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.ref=assertion.ref" \
    --allowed-audiences="//iam.googleapis.com/$PROVIDER_PATH"
fi

echo "Asserting provider allowed audiences and attribute mapping ..."
# Note: Updating allowed audiences if missing/mismatched
set +e
NEEDS_UPDATE=0
gcloud iam workload-identity-pools providers describe "$PROVIDER" \
  --project="$PROJECT_ID" --location=global --workload-identity-pool="$POOL" \
  --format='value(oidc.allowedAudiences)' | grep -q "/$PROVIDER$"
if [[ $? -ne 0 ]]; then
  NEEDS_UPDATE=1
fi
set -e

if [[ $NEEDS_UPDATE -eq 1 ]]; then
  echo "Updating provider allowed audiences ..."
  gcloud iam workload-identity-pools providers update-oidc "$PROVIDER" \
    --project="$PROJECT_ID" --location=global --workload-identity-pool="$POOL" \
    --allowed-audiences="//iam.googleapis.com/$PROVIDER_PATH" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.ref=assertion.ref"
fi

echo "Binding service account to principalSet for repo+branch ..."
OWNER=$(cut -d'/' -f1 <<< "$REPO")
NAME=$(cut -d'/' -f2 <<< "$REPO")

PRINCIPAL="principalSet://iam.googleapis.com/projects/$PN/locations/global/workloadIdentityPools/$POOL/attribute.repository/$OWNER/$NAME/attribute.ref/refs/heads/$BRANCH"

gcloud iam service-accounts add-iam-policy-binding "$SERVICE_ACCOUNT" \
  --project="$PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="$PRINCIPAL"

echo "Service Account bound to principal: $PRINCIPAL"

echo "Provider resource path: //iam.googleapis.com/$PROVIDER_PATH"
if $SET_GH_SECRET; then
  if command -v gh >/dev/null 2>&1; then
    echo "Setting GitHub secret WIF_PROVIDER_DEV ..."
    gh secret set WIF_PROVIDER_DEV --body "projects/$PN/locations/global/workloadIdentityPools/$POOL/providers/$PROVIDER"
  else
    echo "gh CLI not found; skipping secret setup."
  fi
fi

echo "Done. Validate by running a workflow that uses google-github-actions/auth@v2 with:\n  workload_identity_provider: projects/$PN/locations/global/workloadIdentityPools/$POOL/providers/$PROVIDER\n  service_account: $SERVICE_ACCOUNT\n  project_id: $PROJECT_ID"

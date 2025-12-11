#!/usr/bin/env bash
set -euo pipefail

# Usage:
# ./check-wif.sh --project-id PROJECT_ID --pool POOL --provider PROVIDER --service-account SA_EMAIL --repo OWNER/REPO --branch dev

PROJECT_ID=""
POOL=""
PROVIDER=""
SERVICE_ACCOUNT=""
REPO=""
BRANCH="dev"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-id) PROJECT_ID="$2"; shift 2;;
    --pool) POOL="$2"; shift 2;;
    --provider) PROVIDER="$2"; shift 2;;
    --service-account) SERVICE_ACCOUNT="$2"; shift 2;;
    --repo) REPO="$2"; shift 2;;
    --branch) BRANCH="$2"; shift 2;;
    -h|--help) echo "Usage: $0 --project-id PROJECT_ID --pool POOL --provider PROVIDER --service-account SA_EMAIL --repo OWNER/REPO --branch BRANCH"; exit 0;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

PN=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')
echo "Project number: $PN"

echo "1️⃣ Checking provider state..."
STATE=$(gcloud iam workload-identity-pools providers describe "$PROVIDER" \
  --project="$PROJECT_ID" --location=global --workload-identity-pool="$POOL" \
  --format='value(state)')
echo "Provider state: $STATE"

echo "2️⃣ Checking allowed audiences..."
AUDIENCE=$(gcloud iam workload-identity-pools providers describe "$PROVIDER" \
  --project="$PROJECT_ID" --location=global --workload-identity-pool="$POOL" \
  --format='value(oidc.allowedAudiences)')
echo "Allowed audience: $AUDIENCE"

echo "3️⃣ Checking attribute condition..."
ATTR_COND=$(gcloud iam workload-identity-pools providers describe "$PROVIDER" \
  --project="$PROJECT_ID" --location=global --workload-identity-pool="$POOL" \
  --format='value(attributeCondition)')
echo "Attribute condition: $ATTR_COND"

echo "4️⃣ Checking IAM bindings for service account..."
gcloud iam service-accounts get-iam-policy "$SERVICE_ACCOUNT" --project="$PROJECT_ID" \
  --format='yaml(bindings)' | grep -A2 "members:.*$POOL"

echo "5️⃣ Check branch triggers:"
echo "Workflow must run on branch: $BRANCH"

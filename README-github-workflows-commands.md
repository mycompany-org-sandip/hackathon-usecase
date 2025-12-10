# GitHub Workflows: Step-by-Step Commands (zsh)

This guide provides copy-paste commands to run and inspect the repo’s GitHub Actions.
Works with macOS `zsh` and the GitHub CLI (`gh`).

Prerequisites:
- Install GitHub CLI: https://cli.github.com/
- Authenticate: `gh auth login` (choose GitHub.com → HTTPS → login via browser or token)
- Ensure required repository secrets are set (see `README-github-workflows.md`).

## Repo & Branch Basics
```zsh
# Clone and enter repo (if not already)
# gh repo clone reddysandip/hackathon-usecase
cd /Users/sandipreddynukalapati/Desktop/hackathon-usecase

# Check branch
git status
# Current branch should be hackathon-working per context

# Fetch latest
git pull --rebase
```

## Set Required GitHub Secrets via CLI
Replace placeholder values before running.
```zsh
# Workload Identity Provider
gh secret set WIF_PROVIDER --body "projects/<PROJECT_NUMBER>/locations/global/workloadIdentityPools/<pool>/providers/<provider>"

# GCP project
gh secret set GCP_PROJECT_ID --body "<PROJECT_ID>"

# Optional SA key for CD (JSON string)
# If using a file: gh secret set GCP_SA_KEY < gcp-sa-key.json
# Or inline:
gh secret set GCP_SA_KEY --body "{...json-key...}"

# Registries per env
gh secret set DEV_REGISTRY --body "us-docker.pkg.dev/<project>/dev-repo"
gh secret set STG_REGISTRY --body "us-docker.pkg.dev/<project>/stg-repo"
gh secret set PROD_REGISTRY --body "us-docker.pkg.dev/<project>/prod-repo"

# GKE clusters and regions
gh secret set DEV_GKE_CLUSTER --body "<dev-cluster-name>"
gh secret set DEV_GKE_REGION  --body "<dev-region>"

gh secret set STG_GKE_CLUSTER --body "<stg-cluster-name>"
gh secret set STG_GKE_REGION  --body "<stg-region>"

gh secret set PROD_GKE_CLUSTER --body "<prod-cluster-name>"
gh secret set PROD_GKE_REGION  --body "<prod-region>"

# Optional Slack webhook
gh secret set SLACK_WEBHOOK_URL --body "https://hooks.slack.com/services/..."
```

## App CI: Build & Push Images (`.github/workflows/app-ci.yml`)
Trigger by pushing to tracked branches or re-run a workflow.

```zsh
# Push to develop to trigger CI for dev registry
git checkout -b develop || git checkout develop
# Make a small change (optional) to trigger CI
date > .trigger-ci
git add .trigger-ci && git commit -m "chore: trigger CI" && git push -u origin develop

# List recent runs of App CI
gh run list --workflow "App CI - Build & Push Images" --limit 10

# Re-run latest failed run (if any)
RUN_ID=$(gh run list --workflow "App CI - Build & Push Images" --json databaseId --jq '.[0].databaseId')
[[ -n "$RUN_ID" ]] && gh run rerun --run-id "$RUN_ID"

# Watch logs for the latest run
gh run watch --workflow "App CI - Build & Push Images" --exit-status
```

### Retrieve image artifact for CD
```zsh
# Download images.json artifact from latest successful CI run
RUN_ID=$(gh run list --workflow "App CI - Build & Push Images" --json databaseId,status --jq '[.[]|select(.status=="completed")][0].databaseId')
mkdir -p /tmp/images && gh run download "$RUN_ID" --name images --dir /tmp/images
cat /tmp/images/images.json
```

## App CD: Deploy to GKE via Helm (`.github/workflows/app-cd.yml`)
Run manually with `workflow_dispatch` or push to matching branch.

```zsh
# Manual dispatch to deploy (choose branch matching environment)
# dev → develop, staging → staging, prod → main
# Option 1: push to branch to auto-trigger
# Example: trigger staging
# git checkout -b staging || git checkout staging
# date > .trigger-cd && git add . && git commit -m "chore: trigger CD" && git push -u origin staging

# Option 2: workflow dispatch via gh (branch must exist on remote)
BRANCH=develop   # set to staging or main for other envs
gh workflow run "App CD - Deploy to GKE via Helm" -r "$BRANCH"

# Monitor deployment
gh run watch --workflow "App CD - Deploy to GKE via Helm" --exit-status

# Inspect logs
gh run list --workflow "App CD - Deploy to GKE via Helm" --limit 5
RUN_ID=$(gh run list --workflow "App CD - Deploy to GKE via Helm" --json databaseId --jq '.[0].databaseId')
gh run view "$RUN_ID" --log
```

## Terraform: Format & Validate (`.github/workflows/terraform-fmt-validate.yml`)
Runs on any PR.

```zsh
# Create PR to trigger fmt/validate across dev, staging, prod
# Ensure you have a branch to compare
git checkout -b feature/terraform-checks
# Make a small change (optional)
echo "# doc" >> README-commands.md
git add README-commands.md && git commit -m "docs: trigger terraform fmt/validate"
git push -u origin feature/terraform-checks

# Create PR with gh
gh pr create --fill --base main

# Watch the workflow
gh run watch --workflow "Terraform Fmt & Validate" --exit-status
```

## Terraform: Plan (`.github/workflows/terraform-plan.yml`)
Runs on PRs to `main`.

```zsh
# Update PR base to main if not already
PR_NUMBER=$(gh pr list --state open --json number --jq '.[0].number')
[[ -n "$PR_NUMBER" ]] && gh pr edit "$PR_NUMBER" --base main

# Watch the plan runs
gh run watch --workflow "Terraform Plan" --exit-status
```

## Terraform: Apply (`.github/workflows/terraform-apply.yml`)
Runs on push to `main`. Applies in order dev → staging → prod.

```zsh
# Merge to main to trigger apply
# Option A: via PR
PR_NUMBER=$(gh pr list --state open --json number --jq '.[0].number')
[[ -n "$PR_NUMBER" ]] && gh pr merge "$PR_NUMBER" --merge --delete-branch

# Option B: direct push (use cautiously)
git checkout main
# Small change to trigger apply
date > .trigger-apply
git add .trigger-apply && git commit -m "chore: trigger terraform apply" && git push

# Monitor apply runs
gh run watch --workflow "Terraform Apply" --exit-status

# View job sequence and logs
RUN_ID=$(gh run list --workflow "Terraform Apply" --json databaseId --jq '.[0].databaseId')
gh run view "$RUN_ID" --log
```

## Inspect and Download Artifacts
```zsh
# List artifacts for a run
RUN_ID=$(gh run list --workflow "App CI - Build & Push Images" --json databaseId --jq '.[0].databaseId')
gh run view "$RUN_ID" --json artifacts --jq '.artifacts'

# Download a specific artifact
mkdir -p /tmp/artifacts
gh run download "$RUN_ID" --name images --dir /tmp/artifacts
ls -la /tmp/artifacts
```

## Troubleshooting Commands
```zsh
# Check repo and auth context
gh auth status
gh repo view

# Retry a failed run
RUN_ID=$(gh run list --workflow "App CD - Deploy to GKE via Helm" --json databaseId,status --jq '[.[]|select(.status!="completed")][0].databaseId')
[[ -n "$RUN_ID" ]] && gh run rerun --run-id "$RUN_ID"

# Tail logs for a specific job (UI recommended; CLI shows run-level logs)
gh run view "$RUN_ID" --log
```

## Notes
- Branch-to-environment mapping:
  - `develop` → dev, `staging` → staging, `main` → prod.
- Ensure branches exist on remote before `workflow_dispatch` with `-r`.
- If CD fails due to missing `images.json`, re-run App CI or set image values via Helm overrides.

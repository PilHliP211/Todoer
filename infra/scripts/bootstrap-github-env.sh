#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap-github-env.sh --env <staging|prod> [--repo <OWNER/REPO>] [--outputs <path>]

Requires:
  - gh (authenticated with repo access)
  - jq

Populates GitHub environment variables and secrets from infra outputs.
EOF
}

ENVIRONMENT=""
REPO="${GITHUB_REPOSITORY:-}"
OUTPUTS_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --repo)
      REPO="$2"
      shift 2
      ;;
    --outputs)
      OUTPUTS_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$ENVIRONMENT" ]]; then
  echo "Missing required arguments." >&2
  usage
  exit 1
fi

if [[ -z "$REPO" ]]; then
  echo "Missing repository. Set GITHUB_REPOSITORY or pass --repo." >&2
  usage
  exit 1
fi

if [[ -z "$OUTPUTS_PATH" ]]; then
  OUTPUTS_PATH="infra/outputs/${ENVIRONMENT}.json"
fi

if [[ ! -f "$OUTPUTS_PATH" ]]; then
  echo "Outputs file not found: $OUTPUTS_PATH" >&2
  exit 1
fi

project_id=$(jq -r '.project_id' "$OUTPUTS_PATH")
region=$(jq -r '.region' "$OUTPUTS_PATH")
artifact_repo=$(jq -r '.artifact_registry_repo' "$OUTPUTS_PATH")
artifact_location=$(jq -r '.artifact_registry_location' "$OUTPUTS_PATH")
cloud_run_service=$(jq -r '.cloud_run_service_name' "$OUTPUTS_PATH")
runtime_service_account=$(jq -r '.runtime_service_account' "$OUTPUTS_PATH")
workload_identity_provider=$(jq -r '.workload_identity_provider' "$OUTPUTS_PATH")
deployer_service_account=$(jq -r '.deployer_service_account' "$OUTPUTS_PATH")

gh variable set GCP_PROJECT_ID --env "$ENVIRONMENT" --repo "$REPO" --body "$project_id"
gh variable set GCP_REGION --env "$ENVIRONMENT" --repo "$REPO" --body "$region"
gh variable set GCP_ARTIFACT_REGISTRY_REPO --env "$ENVIRONMENT" --repo "$REPO" --body "$artifact_repo"
gh variable set GCP_ARTIFACT_REGISTRY_LOCATION --env "$ENVIRONMENT" --repo "$REPO" --body "$artifact_location"
gh variable set CLOUD_RUN_SERVICE_NAME --env "$ENVIRONMENT" --repo "$REPO" --body "$cloud_run_service"
gh variable set RUNTIME_SERVICE_ACCOUNT --env "$ENVIRONMENT" --repo "$REPO" --body "$runtime_service_account"

gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER --env "$ENVIRONMENT" --repo "$REPO" --body "$workload_identity_provider"
gh secret set GCP_DEPLOYER_SERVICE_ACCOUNT --env "$ENVIRONMENT" --repo "$REPO" --body "$deployer_service_account"

echo "GitHub environment ${ENVIRONMENT} updated for ${REPO}."

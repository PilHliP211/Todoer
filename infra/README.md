# Infrastructure as Code (GCP)

Terraform manages the core GCP baseline for Todoer. This folder includes a bootstrap step for the
remote state bucket plus per-environment configs for staging and prod.

## Prerequisites

- Terraform >= 1.5 (installed locally)
- `gcloud auth application-default login`
- A GCP project for each environment

### Install Terraform

Terraform is not bundled with npm. Install it via one of the official distribution channels:

- Homebrew: `brew install terraform`
- `tfenv`: `tfenv install 1.6.6 && tfenv use 1.6.6`
- Direct download: https://developer.hashicorp.com/terraform/downloads

Ensure the `terraform` CLI is on your `PATH` after installation.

## 1) Bootstrap remote state bucket

The state bucket must exist before Terraform can use the `gcs` backend.

```bash
terraform -chdir=infra/bootstrap init
terraform -chdir=infra/bootstrap apply \
  -var="project_id=todoer-staging" \
  -var="region=us-central1" \
  -var="state_bucket_name=todoer-tf-state-staging"
```

Repeat for prod with its own bucket name (for example, `todoer-tf-state-prod`).

## 2) Initialize Terraform with the remote backend

```bash
terraform -chdir=infra init -backend-config=backend/staging.hcl
```

## 3) Plan and apply

```bash
terraform -chdir=infra plan -var-file=environments/staging.tfvars
terraform -chdir=infra apply -var-file=environments/staging.tfvars
```

## 4) Configure GitHub environments for CD

After applying Terraform, populate GitHub environment variables/secrets from the IaC outputs:

```bash
export GITHUB_REPOSITORY=OWNER/REPO
./infra/scripts/bootstrap-github-env.sh --env staging
./infra/scripts/bootstrap-github-env.sh --env prod
```

Prerequisites:

- `gh auth login` with access to the repository
- `jq` installed locally
- GitHub environments named `staging` and `prod` created in the repo settings

## Outputs

- Terraform outputs expose CD inputs (`project_id`, `region`, `artifact_registry_repo`,
  `cloud_run_service_name`, `runtime_service_account_email`, `workload_identity_provider`,
  `deployer_service_account_email`).
- A canonical JSON file is written to `infra/outputs/<env>.json` for CD and local tooling.

## Notes

- Cloud Run uses a placeholder image; CD updates the image on deploy.
- Runtime and deployer service accounts should remain separate; runtime roles are kept minimal.

# Story 0.4: Infrastructure as Code Baseline (GCP Core)

## User Story

As an operator, I want core GCP infrastructure defined as code so I can reproduce environments and avoid manual drift.

## Acceptance Criteria

- IaC tool selected and repo structure added under `infra/` (or similar) with README for plan/apply.
- Remote state configured (GCS bucket + versioning + state locking) and environment separation for staging and prod.
- IaC provisions required APIs (Artifact Registry, Cloud Run, IAM Credentials, Secret Manager), Artifact Registry repository, Cloud Run services, and runtime service account(s).
- IAM roles for runtime service accounts (Secret Manager access, Cloud SQL client if used) are codified.
- Outputs expose CD inputs (project id, region, artifact repo, Cloud Run service name, runtime SA email).

## Technical Notes

- Prefer Terraform or Pulumi; keep env config in `*.tfvars` or stack configs.
- Keep deployer and runtime service accounts separate.
- Use least-privilege roles; avoid Owner/Editor.
- Cloud Run services can be created with a placeholder image; CD updates the image later.

## Manual Validation

1. Run plan for staging; verify expected resources.
2. Apply for staging; confirm resources exist in GCP and outputs are populated.
3. Re-run plan; expect no drift.
4. Update CD vars from outputs and rerun the pipeline.

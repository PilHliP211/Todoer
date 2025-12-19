# Story 0.5: IaC for GitHub OIDC and CD Access

## User Story

As a developer, I want GitHub OIDC and IAM bindings defined in IaC so CD auth is repeatable and auditable.

## Acceptance Criteria

- Workload Identity Pool and GitHub provider are created via IaC with issuer `https://token.actions.githubusercontent.com` and attribute mappings for `assertion.sub` and `assertion.repository`.
- Provider condition restricts access to the expected repo (and optional branch).
- Deployer service account IAM binding grants `roles/iam.workloadIdentityUser` to `principalSet://.../attribute.repository/OWNER/REPO`.
- Deployer service account roles required by CD (run.admin, artifactregistry.writer, secretmanager.secretAccessor, etc.) are applied via IaC.
- If Cloud Run uses a custom runtime service account, deployer has `roles/iam.serviceAccountUser` on that runtime service account.
- Outputs provide the provider resource name and deployer service account email for GitHub secrets.

## Technical Notes

- Use `principalSet` bindings with `attribute.repository` to avoid subject drift.
- Keep conditions explicit; add `attribute.ref` only if branch restriction is desired.
- Consider managing GitHub environment secrets/vars via GitHub provider or document manual steps.

## Manual Validation

1. Apply IaC; confirm pool and provider exist.
2. Update GitHub secrets from outputs and run CD; auth succeeds.
3. Change repo or branch to a disallowed value; auth fails as expected.

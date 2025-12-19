# Story 0.6: CD to Cloud Run (Staging to Prod)

## User Story

As an operator, I want automated delivery to Cloud Run staging with manual promotion to prod so that releases are consistent and controllable.

## Acceptance Criteria

- CD authenticates to GCP via Workload Identity Federation (no static keys) and configures Docker auth for Artifact Registry.
- CD builds a container image, pushes to Artifact Registry, and deploys to Cloud Run staging on develop/main.
- Manual approval is required to promote the same image tag to production.
- GitHub environments provide per-environment inputs (project, region, artifact repo, service name, min instances, optional secrets).
- If secrets are referenced, the Cloud Run runtime service account has `roles/secretmanager.secretAccessor` on those secrets.
- Deployment metadata (commit SHA, image tag) is set as env vars or logged.
- Pipeline consumes environment variables from a single source (GitHub environments populated from IaC outputs) without per-deploy manual edits.

## Technical Notes

- Use GitHub Actions with `google-github-actions/auth@v2` and `setup-gcloud@v2`.
- Run `gcloud auth configure-docker "${REGION}-docker.pkg.dev"` before `docker push`.
- Compute image tags from `GITHUB_SHA` and reuse the same tag for staging and production.
- Use `gcloud run deploy` with `--set-secrets` only when `CLOUD_RUN_SECRETS` is non-empty.
- Keep a documented rollback procedure (previous revision) in deployment docs.

## Manual Validation

1. Push to `develop`: confirm Artifact Registry image is created and staging deploy succeeds.
2. Verify the Cloud Run revision uses the expected image tag and service account.
3. Approve promotion from `main`: confirm prod deploy uses the same image tag.
4. Hit `/healthz` on staging and prod; expect 200.
5. If secrets are configured, confirm they are available at runtime (startup logs show non-empty config).
6. Confirm no manual environment variable updates were needed beyond the bootstrap step.

# Story 0.4: CD to Cloud Run (Staging → Prod)

## User Story
As an operator, I want automated delivery to Cloud Run staging with manual promotion to prod so that releases are consistent and controllable.

## Acceptance Criteria
- CD builds container image, pushes to Artifact Registry, deploys to Cloud Run staging on successful CI.
- Manual approval step required to promote the same image to prod.
- Environment variables reference Secret Manager; no secrets inline.
- Minimum instances set to reduce cold starts.
- Deployment metadata (commit SHA, image tag) logged.

## Technical Notes
- Use Cloud Build triggers or GitHub Actions with gcloud auth to deploy.
- Parameterize service name, region, and project per environment.
- Run migrations against staging DB before staging deploy; run against prod before promotion (guarded).
- Rollback procedure documented (previous revision).

## Manual Validation
1) Trigger CD (merge to main): confirm staging deploy succeeds and health checks pass.
2) Verify image tag in staging matches commit SHA.
3) Approve promotion: confirm prod deploy uses same image tag.
4) Hit `/healthz` on staging and prod; expect 200.
5) Confirm Secret Manager-based env vars are loaded (e.g., inspect logs for startup config keys present/not empty).

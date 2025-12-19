# Story 0.7: Secrets, Migrations, and Logging Baseline

## User Story

As an operator, I want secrets management, database migrations, and structured logging in place so that deployments are safe and observable.

## Acceptance Criteria

- Secrets pulled from Secret Manager; no secrets in repo or plaintext env files. `.env.example` lists required keys.
- Cloud Run runtime service account has `roles/secretmanager.secretAccessor` for secrets referenced in `CLOUD_RUN_SECRETS`.
- Prisma migrations scaffolded; a baseline migration can run successfully against staging/prod DBs.
- Migration step included in CI/CD before deploy; fails the pipeline on error.
- Structured logging (JSON) with correlation/request IDs for all requests, including health/readiness.
- Basic alert configured on deployment/migration failures (or surfaced via CI/CD notification).

## Technical Notes

- Configure Secret Manager access for the Cloud Run runtime service account; environment variables reference secret versions.
- If no secrets are required, leave `CLOUD_RUN_SECRETS` empty to avoid deploy errors.
- Migration command (e.g., `prisma migrate deploy`) invoked in pipeline.
- Logging middleware attaches correlation ID (generate if missing) and logs request method/path/status/duration.
- Keep baseline schema minimal (e.g., `_prisma_migrations` plus placeholder table) to validate connectivity.

## Manual Validation

1. Run migration step against staging DB; confirm success and table presence.
2. Deploy service and call an endpoint; inspect Cloud Logging entry for correlation ID and structured fields.
3. Verify app starts without local secret files (pulls from Secret Manager in cloud); locally, uses `.env` with placeholders.
4. Trigger a forced migration failure (e.g., bad migration) in a test branch; ensure pipeline fails before deploy.

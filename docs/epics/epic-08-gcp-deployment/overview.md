# EPIC 8: Google Cloud Deployment

## Scope
- Deploy backend to GCP with secure secrets, database, logging, and CI/CD.

## Goals
- Repeatable, secure Cloud Run + Cloud SQL deployment with migrations and observability.

## Acceptance Criteria
- Cloud Run service deployed with min instances set to reduce auth latency; single region for v1.
- Cloud SQL (PostgreSQL) with private connection; migrations run automatically on deploy and are idempotent.
- Secrets stored in Secret Manager; environment variables reference secret versions; no secrets in repo.
- Structured logging to Cloud Logging with correlation IDs; alerts on auth failure spikes and SMS send failures.
- CI/CD pipeline builds, tests, deploys to staging; manual gate promotes to production; rollback to previous revision documented.
- Health (`/healthz`) and readiness endpoints available for probes.

## Interfaces
- Deployment pipeline steps: build container, run tests, run migrations, deploy to staging, promote to prod.
- Ops endpoints: `GET /healthz`, `GET /readiness` (unauthenticated).

## Data Notes
- DB connectivity via Cloud SQL connector or private VPC; ensure minimal privileges for service account.
- Backups for Cloud SQL enabled with retention policy; restore runbook documented.

## Risks / Questions
- SMS provider networking (egress) from Cloud Run—does it require static IP/NAT?
- Observability stack for metrics/alerts (Cloud Monitoring policies to be defined).


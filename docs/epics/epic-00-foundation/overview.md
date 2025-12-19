# EPIC 0: Platform Foundation

## Scope
- Bootstrap deployable backend skeleton on GCP with minimal API surface, tests, and CI/CD.
- Establish infrastructure primitives (container build, Cloud Run, Cloud SQL connectivity, secrets).

## Goals
- Have a single, running endpoint and health checks deployed to staging/prod.
- Linting, unit tests, and integration tests wired into CI/CD.
- Secret and config management in place from day one.

## Acceptance Criteria
- Repo scaffold with Node.js 20 + TypeScript, Fastify, ESLint/Prettier, Vitest (unit) and Supertest (integration).
- Single API endpoint live in staging/prod (e.g., `GET /healthz` or `GET /ping`) plus readiness endpoint.
- CI pipeline: install deps, lint, type-check, unit + integration tests, build container; fail fast on violations.
- CD pipeline: build container (Cloud Build or GH Actions) → push to Artifact Registry → deploy to Cloud Run (staging), with manual promotion to prod.
- Migrations tooling present (Prisma) even if schema minimal; migration step executed in pipeline before deploy.
- Secrets pulled from Secret Manager; no secrets in repo; `.env.example` provided.
- Logging structured with correlation IDs; basic alert on deployment failures.

## Interfaces
- `GET /healthz` (liveness)
- `GET /readiness` (dependency check)

## Data Notes
- Initialize Prisma schema with placeholder table or baseline migration to validate pipeline.
- Cloud SQL connectivity configured (connector or private VPC) even if DB is minimally used in v1 bootstrap.

## Decisions
- Keep foundation minimal: only health endpoint and test scaffolding.
- No NAT/static IP for outbound by default; add later if required.
- Manual approval step between staging and production deploys.

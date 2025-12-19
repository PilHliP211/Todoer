# Tech Stack (GCP-First, Backend-Only V1)

This stack is optimized for a TypeScript API deployed entirely on GCP, with future frontend compatibility in mind (frontend deferred for now).

---

## Runtime and Framework
- Node.js 20 LTS with TypeScript.
- Fastify for a lightweight, high-performance HTTP server with first-class TypeScript support.
- Zod for runtime validation and schema reuse (can drive OpenAPI generation).
- JWT-based auth tokens (signed with Secret Manager key); magic-link tokens stored hashed.

## Data and Persistence
- Cloud SQL (PostgreSQL) as the primary database.
- Prisma ORM for migrations, schema, and type-safe data access.
- Row-level access via explicit `taskListId` scoping and indexes; no cross-tenant joins.
- Connection management via Cloud SQL connector; pool settings tuned for Cloud Run.

## API Contract and Tooling
- OpenAPI auto-generated from Fastify + Zod schemas (fastify-swagger or similar).
- Supertest/Vitest for request-level tests; ESLint + Prettier for consistency.
- Structured error envelope for all endpoints; ISO 8601 UTC timestamps.
- Pagination uses opaque cursor tokens; error codes constrained to `invalid_input`, `unauthorized`, `forbidden`, `not_found`, `conflict`, `rate_limited`, `internal_error`.

## Messaging (SMS)
- SMS provider: Twilio for magic links.
- Outbound egress from Cloud Run without NAT by default; add Serverless VPC Connector + Cloud NAT only if Twilio requires fixed IP allowlisting.
- Magic-link URL uses purchased domain over HTTPS (e.g., `https://{domain}/login?token=...`).
- SMS templates kept in code/config; secrets (API keys) in Secret Manager.

## Platform and Deployment
- Container image built with Cloud Build (or GitHub Actions) and stored in Artifact Registry.
- Deploy to Cloud Run (min instances > 0 to reduce auth latency).
- Migrations executed in CI/CD prior to deploy (Prisma migrate).
- Config via environment variables referencing Secret Manager versions.

## Observability and Ops
- Cloud Logging with structured logs and correlation IDs.
- Cloud Error Reporting for exceptions; Cloud Trace for latency profiling if needed.
- Health and readiness endpoints for probes; alerting on auth failure spikes and SMS send failures.
- Backups enabled for Cloud SQL with documented restore runbook.

## Rate Limiting and Caching (Optional for V1)
- Per-phone rate limits for login requests enforced in DB (5/hour default); caching layer (Cloud Memorystore) only if higher throughput is needed later.
- IP-based throttling skipped in v1; can be added via Cloud Armor if required.

## Security and Secrets
- Secrets in Secret Manager; no secrets in source control.
- Service accounts with least privilege for Cloud Run and Cloud SQL access.
- Tokens and passwords hashed; PII masked in logs (phone numbers to last 4 digits).

## Future Frontend (Not in V1)
- Recommended: React/Next.js with TypeScript.
- Deployment options on GCP: static export to Cloud Storage + Cloud CDN, or server-rendered via Cloud Run.

## Local Development
- pnpm or npm as package manager; docker-compose for running Postgres locally.
- Env management via `.env.example` (no secrets); scripts for lint, test, and type-check.

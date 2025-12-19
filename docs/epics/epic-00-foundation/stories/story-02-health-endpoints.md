# Story 0.2: Health and Readiness Endpoints Deployed

## User Story
As an operator, I want health and readiness endpoints live in staging/prod so that monitoring and deployment checks can validate service health.

## Acceptance Criteria
- `GET /healthz` returns 200 with static payload when process is up.
- `GET /readiness` returns 200 only when downstream dependencies (e.g., DB) are reachable; returns 503 otherwise.
- Endpoints are unauthenticated and deployed to staging and prod Cloud Run services.
- Structured logging includes correlation/request IDs on these endpoints.

## Technical Notes
- Implement as Fastify routes; reuse app instance for tests.
- Readiness should check DB connectivity via Prisma or low-cost query; time out reasonably.
- Include minimal payload shape: `{ status: "ok", uptimeSeconds, version? }`.
- Ensure these endpoints are excluded from auth middleware.

## Manual Validation
1) Call `GET /healthz` in staging: expect 200 and JSON payload with status ok.
2) Call `GET /readiness` with DB reachable: expect 200 and readiness payload.
3) Temporarily break DB connectivity (or point to bad DB) and call `/readiness`: expect 503.
4) Check logs for requests including correlation IDs.

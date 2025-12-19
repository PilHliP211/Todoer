# EPIC 7: API Contract

## Scope
- Define a consistent, tenant-aware API surface with stable versioning and error handling.

## Goals
- Predictable JSON contracts, pagination, and validation errors.
- Generate and publish OpenAPI from TypeScript types.

## Acceptance Criteria
- All endpoints under `/api/v1`; health endpoints excluded.
- Standard error envelope: `{ error: { code, message, details? } }`.
- Pagination for list endpoints via `limit` and `cursor` (or `pageToken`) with stable sort (`createdAt`, `id`).
- Validation errors return 400 with field-level detail; auth 401; permission 403; not found 404.
- OpenAPI/Swagger generated in CI and published with releases.

## Interfaces (Summary)
- Auth: magic-link request/verify, logout.
- Task lists: create/list/archive (super admin).
- Memberships: create/list/update.
- Tasks: create/list/update/archive; assignments create/delete.
- Completions: create/list (admin) and list self.
- Ops: health/readiness (unauthenticated).

## Data Notes
- Consistent timestamp format (ISO 8601 UTC).
- Tenant context derived from token; super admin may pass explicit tenant header.

## Decisions
- Pagination uses opaque cursor tokens (no offsets).
- Error codes limited to: `invalid_input`, `unauthorized`, `forbidden`, `not_found`, `conflict`, `rate_limited`, `internal_error`.

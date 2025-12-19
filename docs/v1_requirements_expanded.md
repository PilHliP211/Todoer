# V1 Requirements Expansion (Addendum)

This document expands the initial requirements in `docs/v1_requirements.md` with testable acceptance criteria, data model notes, and operational expectations for the backend-only v1. Existing files remain unchanged.

---

## Scope Notes (V1)
- Included: multi-tenant API, SMS magic-link auth, role-based access control, task assignment/completion with points, Cloud deployment.
- Excluded: any UI, gamification beyond storing points, advanced scheduling/recurrence, exports, notifications other than login SMS.

---

## Non-Functional Requirements
- **Isolation**: every request is scoped to `taskListId`; no cross-tenant reads or leaks in responses, errors, or logs.
- **Security**: store magic-link tokens hashed; JWT/session secrets in Secret Manager only; do not log full phone numbers (mask to last 4).
- **Performance**: p50 < 300ms, p95 < 1s for CRUD endpoints under nominal load; auth endpoints warmed to avoid cold-start delays.
- **Availability**: single region Cloud Run + Cloud SQL; clear errors if SMS provider unavailable; health/readiness endpoints for probes.
- **Auditability**: record actor, action, target, timestamp, and metadata for admin and role-affecting changes.
- **Rate Limits**: login requests per phone number (e.g., 5/hour) and per IP if available; 429 with retry-after hint.
- **Timezone/Clock**: store timestamps in UTC; rely on server time sync; no client timezone logic in v1.

---

## Data Model (Draft)
- **User**: `id`, `phoneNumber` (unique), `createdAt`, `updatedAt`.
- **TaskList**: `id`, `name`, `status` (active/archived), `createdAt`, `createdBy`.
- **Membership**: `id`, `userId`, `taskListId`, `role` (admin/user), `status` (active/disabled), `createdAt`, `updatedAt`. Unique `(userId, taskListId)`.
- **Task**: `id`, `taskListId`, `title`, `description`, `priority` (low/medium/high), `points` (int >= 0), `status` (active/archived), `createdAt`, `updatedAt`, `createdBy`.
- **Assignment**: `id`, `taskId`, `assigneeType` (user/all), `assigneeId` (nullable when all), `createdAt`, `createdBy`. A task can have at most one "all" assignment; user assignments unique per `(taskId, userId)`.
- **Completion**: `id`, `taskId`, `userId`, `taskListId`, `completedAt`, `pointsAwarded`, `createdAt`. Unique `(taskId, userId)` for idempotency.
- **MagicLink**: `id`, `userId`, `taskListId` (nullable for super admin scope), `tokenHash`, `expiresAt`, `usedAt`, `createdAt`, `createdByRequestId`.
- **AuditEvent**: `id`, `taskListId` (nullable for global), `actorUserId`, `action`, `targetType`, `targetId`, `metadata`, `createdAt`.

---

## Acceptance Criteria by Epic

### EPIC 1: Multi-Tenant Task List Foundation
- All resource queries filter by `taskListId`; super admin calls must declare target tenant.
- Task lists can be created, listed, and archived; archived lists block new logins and task mutations.
- Cross-tenant access attempts return 403 without leaking existence of other tenants.

### EPIC 2: Roles and Permissions
- Role matrix enforced on every endpoint (super admin > admin > user). Unauthorized actions return 403 with standard error shape.
- Admins cannot elevate to super admin; users cannot self-elevate.
- Automated tests cover permission boundaries for each endpoint.

### EPIC 3: SMS Magic Link Authentication
- `POST /auth/magic-link/request`: accepts `phoneNumber`, `taskListId`; rejects if phone not allowlisted for that tenant; applies rate limit.
- SMS includes app name, task list name, expiry time; no PII besides masked phone and link.
- `POST /auth/magic-link/verify`: single-use token, expires in 15 minutes (configurable); on success issues JWT/session scoped to user + taskListId and marks token used.
- Used or expired tokens return 401 with consistent error payload.

### EPIC 4: User and Membership Management
- Admin can add a membership by phone number (creates user if not exists) and set role (admin/user).
- Admin can list memberships for their task list; super admin can list any.
- Admin can disable or change role for a membership; disabled members cannot authenticate or complete tasks in that task list.
- All membership changes emit audit events with actor and target recorded.

### EPIC 5: Task Creation and Assignment
- Admin can create tasks with required fields: `title`, `points`, `priority`; optional `description`.
- Admin can assign tasks to a specific user membership or to all users; assignments are validated to belong to the same task list.
- Admin can edit task fields and reassign; edits update `updatedAt` and create audit entries.
- Archived tasks are excluded from active lists and cannot be completed.

### EPIC 6: Task Completion and Points
- Users can view tasks assigned to them and all-user tasks in their task lists.
- `POST /tasks/:id/complete` is idempotent per `(taskId, userId)`; duplicates rejected with 409 or treated as no-op without double points.
- Completion records include `pointsAwarded` and `completedAt`; totals derivable per user per task list.
- Admin can list completions by task list; users can list their own completions.

### EPIC 7: API Contract
- All endpoints under `/api/v1`; JSON responses; errors follow `{ error: { code, message, details? } }`.
- List endpoints support pagination via `limit` and `cursor` (or `pageToken`) with stable sorting by `createdAt` then `id`.
- Validation errors return 400 with field-level details; auth 401; permission 403; not found 404.
- OpenAPI generated from TypeScript types and published with releases.

### EPIC 8: Google Cloud Deployment
- Cloud Run deployment with min instances set to reduce auth latency; Cloud SQL (PostgreSQL) with private connection.
- Secrets in Secret Manager; environment variables reference secret versions; no secrets committed.
- Migrations run automatically on deploy (prisma/migrate or equivalent) and are idempotent.
- Structured logging to Cloud Logging with correlation IDs; alerts on auth failure spikes and SMS send failures.
- CI/CD: build, test, and deploy to staging; manual promotion to production.

---

## API Surface (V1 Summary)
- Auth: `POST /auth/magic-link/request`, `POST /auth/magic-link/verify`, `POST /auth/logout`.
- Task lists (super admin): `POST /task-lists`, `GET /task-lists`, `PATCH /task-lists/:id` (name/status).
- Memberships: `POST /task-lists/:id/memberships`, `GET /task-lists/:id/memberships`, `PATCH /memberships/:id` (role/status).
- Tasks: `POST /task-lists/:id/tasks`, `GET /task-lists/:id/tasks`, `PATCH /tasks/:id`, `POST /tasks/:id/assignments`, `DELETE /assignments/:id`, `PATCH /tasks/:id/archive`.
- Completions: `POST /tasks/:id/complete`, `GET /task-lists/:id/completions` (admin), `GET /me/completions`.
- Ops: `GET /healthz`, `GET /readiness`.

All endpoints except health and magic-link request/verify require authenticated tokens; tenant context derived from token or explicit header when super admin acts across tenants.

---

## Operational and Quality Gates
- Unit and integration tests cover auth flows, permission boundaries, idempotent completions, and pagination.
- Smoke tests for deployment (health, readiness, DB connectivity, SMS provider connectivity).
- Backup and restore runbook for Cloud SQL; daily backups retained per policy.
- Rollback plan for failed deploys (previous Cloud Run revision and migration strategy).

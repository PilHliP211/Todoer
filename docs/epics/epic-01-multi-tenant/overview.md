# EPIC 1: Multi-Tenant Task List Foundation

## Scope
- Ensure strict tenant isolation for all data and requests.
- Support creation, listing, and archival of task lists (tenants).

## Goals
- Every resource is scoped by `taskListId`; no cross-tenant leakage.
- Super admins can operate across tenants; others cannot.

## Acceptance Criteria
- All queries and writes require `taskListId`; super admin calls specify tenant explicitly.
- Users can access only tenants where they have an active membership.
- Archived task lists block new logins and task mutations.
- Cross-tenant access attempts return 403 with a consistent error envelope.

## Interfaces
- `POST /task-lists` (super admin)
- `GET /task-lists` (super admin list)
- `PATCH /task-lists/:id` (rename/archive)

## Data Notes
- `TaskList`: `id`, `name`, `status` (active/archived), timestamps, `createdBy`.
- Tenant foreign key on all scoped tables; indexes include `taskListId`.

## Risks / Questions
- Do we need soft-delete versus archive? (Current: archive only.)
- Tenant naming uniqueness rules (global or per owner?).


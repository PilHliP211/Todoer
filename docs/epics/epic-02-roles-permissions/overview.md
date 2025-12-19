# EPIC 2: Roles & Permissions

## Scope

- Define and enforce role-based access control for super admins, task list admins, and users.

## Goals

- Enforce least privilege across all endpoints.
- Provide clear, consistent error responses for permission failures.

## Acceptance Criteria

- Role matrix enforced on every protected endpoint:
  - Super Admin: manage any tenant, seed first admin, create/archive task lists.
  - Task List Admin: manage memberships and tasks in their tenant; cannot create super admins.
  - User: view and complete their tasks; view own points/completions.
- Unauthorized actions return 403 with standard error shape.
- Automated tests cover permission boundaries for each endpoint.

## Interfaces (Examples)

- Membership changes (admin/super): `POST /task-lists/:id/memberships`, `PATCH /memberships/:id`.
- Task management (admin/super): `POST /task-lists/:id/tasks`, `PATCH /tasks/:id`, assignments.
- Completion (user/admin): `POST /tasks/:id/complete`, `GET /me/completions`.

## Data Notes

- `Membership.role` in {admin, user}; super admin tracked separately (e.g., flag on `User` or join table).
- Permission checks keyed on `(userId, taskListId, role, status)`.

## Decisions

- Super admins modeled as a boolean/flag on `User` (no separate table in v1).
- No read-only admin role in v1.

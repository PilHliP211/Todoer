# EPIC 4: User & Membership Management

## Scope
- Manage users by phone number and their memberships/roles per task list.

## Goals
- Allow admins to onboard and control access without needing a frontend.
- Ensure users can belong to multiple task lists with independent roles/status.

## Acceptance Criteria
- Admin can add membership by phone number (create user if none) with role admin/user.
- Memberships listable per task list (admin) and globally (super admin).
- Admin can change role or disable membership; disabled members cannot authenticate or complete tasks for that task list.
- All membership changes emit audit events (actor, target, action, timestamp).

## Interfaces
- `POST /task-lists/:id/memberships`
- `GET /task-lists/:id/memberships`
- `PATCH /memberships/:id` (role/status)

## Data Notes
- `User`: `id`, `phoneNumber` (unique), timestamps.
- `Membership`: `id`, `userId`, `taskListId`, `role` (admin/user), `status` (active/disabled), unique `(userId, taskListId)`.

## Risks / Questions
- Invite flow messaging when user already exists on another task list (should succeed if allowlisted).
- Should disabled memberships revoke active sessions immediately? (Recommended: yes.)


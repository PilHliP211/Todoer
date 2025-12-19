# EPIC 6: Task Completion & Points

## Scope
- Allow users to complete assigned tasks once; record completions and points.

## Goals
- Idempotent completion, accurate point totals, and clear visibility for admins.

## Acceptance Criteria
- Users can view tasks assigned to them and all-user tasks in their task lists.
- `POST /tasks/:id/complete` is idempotent per `(taskId, userId)`; duplicates rejected with 409 or treated as no-op without double points.
- Completion records capture `pointsAwarded` and `completedAt`; totals derivable per user per task list.
- Admin can list completions by task list; users can list their own completions.
- Archived tasks cannot be completed.

## Interfaces
- `POST /tasks/:id/complete`
- `GET /task-lists/:id/completions` (admin)
- `GET /me/completions`

## Data Notes
- `Completion`: `id`, `taskId`, `userId`, `taskListId`, `completedAt`, `pointsAwarded`, `createdAt`. Unique `(taskId, userId)`.
- Totals can be derived via aggregation; cached totals optional but not required for v1.

## Risks / Questions
- Manual adjustments to points? (Not in scope for v1; if added, must be audited.)
- Should completions allow backdating? (Recommend: use server time only in v1.)


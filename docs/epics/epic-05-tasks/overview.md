# EPIC 5: Task Creation & Assignment

## Scope
- Create, edit, and archive tasks; assign to a user or to all users in a task list.

## Goals
- Simple, reliable task management with clear ownership and auditability.

## Acceptance Criteria
- Admin can create tasks with required fields: `title`, `points`, `priority`; optional `description`.
- Admin can assign a task to a specific membership or to all users; validations ensure same `taskListId`.
- Admin can edit tasks and reassign; updates refresh `updatedAt` and add audit entries.
- Tasks can be archived; archived tasks excluded from active lists and cannot be completed.
- Validation: `points` non-negative integer; `priority` in {low, medium, high}.

## Interfaces
- `POST /task-lists/:id/tasks`
- `GET /task-lists/:id/tasks`
- `PATCH /tasks/:id`
- `POST /tasks/:id/assignments`
- `DELETE /assignments/:id`
- `PATCH /tasks/:id/archive`

## Data Notes
- `Task`: `id`, `taskListId`, `title`, `description`, `priority`, `points`, `status` (active/archived), timestamps, `createdBy`.
- `Assignment`: `id`, `taskId`, `assigneeType` (user/all), `assigneeId` nullable when all, timestamps, `createdBy`. Unique `(taskId, userId)` per user assignments; only one "all" assignment.

## Risks / Questions
- Need for assignment history? (Current: not required; audit captures changes.)
- Do we need due dates/recurrence in v1? (Out of scope.)


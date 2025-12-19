# EPIC 3: SMS Magic Link Authentication

## Scope

- Passwordless login via single-use SMS magic links scoped to a task list.

## Goals

- Secure, rate-limited login by phone number with clear UX and error handling.
- Minimal PII exposure in logs and messages.

## Acceptance Criteria

- `POST /auth/magic-link/request` accepts `phoneNumber`, `taskListId`; rejects if not allowlisted for that tenant.
- Rate limits per phone: 5 requests/hour; IP-based throttling deferred. Returns 429 with retry hint.
- SMS includes app name, task list name, expiry time; no sensitive data beyond the link.
- `POST /auth/magic-link/verify` accepts single-use token; expires in ~15 minutes (configurable); on success issues JWT/session scoped to user + taskListId and marks token used.
- Used/expired/invalid tokens return 401 with consistent error envelope.
- Tokens stored hashed at rest; no raw token persisted.

## Interfaces

- `POST /auth/magic-link/request`
- `POST /auth/magic-link/verify`
- `POST /auth/logout`

## Data Notes

- `MagicLink`: `id`, `userId`, `taskListId` (nullable for super admin scope), `tokenHash`, `expiresAt`, `usedAt`, `createdAt`, `createdByRequestId`.
- Store phone in E.164; mask to last 4 digits in logs.

## Decisions

- SMS provider: Twilio; sender aligned to purchased domain/brand.
- Magic-link URL: `https://{yourdomain}/login?token=...` (https required).
- Per-phone rate limit 5/hour; skip IP throttling in v1.

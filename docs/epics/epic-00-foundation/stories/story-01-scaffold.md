# Story 0.1: Backend Scaffold with Tooling

## User Story
As a developer, I want a TypeScript/Fastify backend scaffold with linting, testing, and formatting so that I can build features confidently on a consistent foundation.

## Acceptance Criteria
- Repo initializes Node.js 20 + TypeScript + Fastify.
- ESLint + Prettier configured with npm scripts to run lint/format checks.
- Vitest configured for unit tests; Supertest available for HTTP-level tests.
- Base folder structure created (`src/`, `tests/`, `scripts/` if needed).
- `.env.example` present with required keys (no secrets).

## Technical Notes
- Prefer pnpm or npm scripts: `lint`, `format`, `test:unit`, `test:integration`, `build`, `dev`.
- Fastify instance exported from `src/app.ts` to share between server and tests.
- TypeScript config targeting Node 20; strict type-checking enabled.
- Ensure commit hooks optional; CI will enforce quality gates.

## Manual Validation
1) Run `npm install` (or pnpm) and ensure dependencies install cleanly.
2) Run `npm run lint` and verify it passes.
3) Run `npm run test:unit` and `npm run test:integration` (should pass with placeholder tests).
4) Confirm `.env.example` exists and contains non-secret placeholders.

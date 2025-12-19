# Story 0.3: CI Quality Gates

## User Story

As a developer, I want CI to enforce code quality and tests so that regressions are caught before deploy.

## Acceptance Criteria

- CI workflow runs on PRs and main branch.
- Steps: install deps, lint, type-check, unit tests, integration tests (against local DB or service container), build.
- CI fails on any lint/type/test/build error.
- Artifacts (e.g., coverage, build output) uploaded or cached as needed.

## Technical Notes

- Use Cloud Build or GitHub Actions; keep steps consistent with package scripts.
- For integration tests, spin up ephemeral Postgres (service container) and run migrations before tests.
- Cache npm/pnpm to speed builds; pin Node 20 in CI.
- Ensure CI uses `.env.example` + test overrides; no real secrets.

## Manual Validation

1. Push a branch/PR: verify CI pipeline runs all steps and passes.
2. Introduce a lint error locally and push: CI should fail on lint step.
3. Break a unit test locally and push: CI should fail tests.
4. Confirm build artifact or cache is produced per workflow design.

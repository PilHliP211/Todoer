# Task Checklist App (Multi-Tenant, SMS Auth)

## Overview

This project is a **multi-tenant checklist/task application** designed for use in veterinary clinics, with the ability to **reuse the same system across multiple locations**.

The app is intentionally simple in its first version:

- Admins create and assign tasks
- Users complete tasks
- Completing tasks awards points (for future gamification)
- Authentication is handled via **SMS magic-link URLs**
- The backend is a **TypeScript API deployed on Google Cloud**
- Frontend is intentionally out of scope for v1

This README captures the **initial product requirements, epics, and user stories** agreed upon during early planning.

---

## Core Concepts

### Task List (Tenant)

- Represents a single clinic/location
- All data is scoped to a task list
- Users may belong to multiple task lists

### Roles

- **Super Admin** – Creates task lists and seeds initial admins
- **Task List Admin** – Manages users and tasks within a task list
- **User** – Completes assigned tasks

### Authentication

- Phone number–based identity
- One-time SMS login URLs (“magic links”)
- Users must be allowlisted by an admin to access a task list

---

## V1 Scope (Non-Optional)

Included in v1:

- Multi-tenant architecture
- Role-based permissions
- SMS magic-link authentication
- User allowlisting by phone number
- Task creation and assignment
- Task completion and point awarding
- TypeScript API
- Google Cloud deployment

Out of scope for v1:

- Gamification features beyond point storage
- Advanced scheduling/recurrence
- Frontend/UI

---

## Epic Breakdown

### EPIC 1: Multi-Tenant Task List Foundation

Support multiple clinics/locations with strict data isolation.

### EPIC 2: Roles & Permissions

Define and enforce super admin, admin, and user behavior.

### EPIC 3: SMS Magic Link Authentication

Passwordless login using one-time SMS URLs.

### EPIC 4: User & Membership Management

Admins manage users by phone number per task list.

### EPIC 5: Task Creation & Assignment

Admins create tasks and assign them to users or all users.

### EPIC 6: Task Completion & Points

Users complete tasks and earn points, once per task.

### EPIC 7: API Contract

Clean, tenant-aware TypeScript API for all functionality.

### EPIC 8: Google Cloud Deployment

Production-ready deployment with secure secrets and logging.

---

## User Stories (Minimal)

### EPIC 1: Multi-Tenant Task List Foundation

- As a super admin, I can create a new task list.
- As the system, all data is scoped to a task list.
- As a user, I can only access task lists I belong to.

### EPIC 2: Roles & Permissions

- As a super admin, I can assign an admin to a task list.
- As an admin, I can manage tasks and users in my task list.
- As a user, I cannot create or edit tasks.
- As the system, permissions are enforced at the API level.

### EPIC 3: SMS Magic Link Authentication

- As a user, I can request a login link with my phone number.
- As the system, I send a one-time, expiring SMS URL.
- As the system, only allowlisted phone numbers may log in.
- As the system, magic links can only be used once.

### EPIC 4: User & Membership Management

- As an admin, I can add users by phone number.
- As an admin, I can assign roles to users.
- As a user, I can belong to multiple task lists.
- As an admin, I can disable a user’s access.

### EPIC 5: Task Creation & Assignment

- As an admin, I can create tasks with description, priority, and points.
- As an admin, I can assign tasks to a user.
- As an admin, I can assign tasks to all users.
- As an admin, I can edit or archive tasks.

### EPIC 6: Task Completion & Points

- As a user, I can view tasks assigned to me or all users.
- As a user, I can complete a task once.
- As the system, points are awarded on completion.
- As the system, double completion is prevented.
- As an admin, I can view completion records.

### EPIC 7: API Contract

- As a client, I can perform all actions via a TypeScript API.
- As the system, all requests are authenticated and tenant-scoped.
- As the system, API responses are consistent.

### EPIC 8: Google Cloud Deployment

- As a developer, I can deploy the API to Google Cloud.
- As the system, secrets are stored securely.
- As a developer, I can view logs and errors.

---

## Deliverables for V1

1. Multi-Tenant Architecture & Data Isolation Spec
2. Roles, Permissions & Authorization Matrix
3. Authentication & Onboarding Flow Specification
4. User, Membership & Identity Model Spec
5. Task Model & Assignment Rules Specification
6. Task Completion & Points Accounting Spec
7. API Contract & Endpoint Specification
8. Google Cloud Deployment & Environment Spec

---

## Next Steps

- Convert each epic into story-level acceptance criteria
- Define database schema and migrations
- Implement authentication and tenancy first
- Build task creation and completion flows
- Add frontend later against the stable API

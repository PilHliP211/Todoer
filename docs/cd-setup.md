# Continuous Deployment Setup (Cloud Run)

This guide walks through the remaining setup needed to enable the CD pipeline in `.github/workflows/cd.yml`.

## 1) Create GCP resources

1. **Select a project** for staging and production (can be the same or separate).
2. **Create an Artifact Registry repository** (Docker format). Example:
   ```bash
   gcloud artifacts repositories create todoer-images \
     --repository-format=docker \
     --location=us-central1 \
     --description="Todoer images"
   ```
3. **Create Cloud Run services** (staging + prod). You can create empty services or let the CD pipeline create/update them on first deploy.
4. **Create/confirm Secret Manager secrets** for runtime configuration. The current service only needs `DATABASE_URL` (optional). Example:
   ```bash
   gcloud secrets create todoer-database-url --replication-policy="automatic"
   printf "%s" "postgres://..." | gcloud secrets versions add todoer-database-url --data-file=-
   ```

## 2) Create a deployment service account

Create a service account that GitHub Actions will impersonate via Workload Identity Federation:

```bash
gcloud iam service-accounts create todoer-deployer \
  --display-name="Todoer GitHub Actions Deployer"
```

Grant it minimum roles (adjust to your org policies):

- `roles/run.admin` (deploy to Cloud Run)
- `roles/iam.serviceAccountUser` on the **runtime** Cloud Run service account (if distinct)
- `roles/artifactregistry.writer` (push images)
- `roles/secretmanager.secretAccessor` (read secrets)
- `roles/cloudsql.client` (if using Cloud SQL)

## 3) Configure Workload Identity Federation (GitHub → GCP)

Follow the GitHub OIDC + Workload Identity Federation setup steps and create a provider that trusts your repo. You will need:

- **Workload Identity Provider resource name**
- **Service account email** from the previous step

These become GitHub secrets (see next section).

## 4) Configure GitHub Environments

Create **two GitHub environments**: `staging` and `production`.

- In `production`, **require reviewers** to enforce manual promotion.
- Store variables/secrets separately per environment (so prod/staging can diverge).

### Required GitHub Secrets (per environment)

| Name | Purpose |
| --- | --- |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Workload Identity Provider resource name |
| `GCP_SERVICE_ACCOUNT` | Deployer service account email |

### Required GitHub Variables (per environment)

| Name | Example | Purpose |
| --- | --- | --- |
| `GCP_PROJECT_ID` | `todoer-staging` | GCP project ID |
| `GCP_REGION` | `us-central1` | Cloud Run region |
| `GCP_ARTIFACT_REGION` | `us-central1` | Artifact Registry region |
| `GCP_ARTIFACT_REPOSITORY` | `todoer-images` | Artifact Registry repo name |
| `CLOUD_RUN_SERVICE` | `todoer-api-staging` | Cloud Run service name |
| `CLOUD_RUN_MIN_INSTANCES` | `1` | Min instances to reduce cold starts |
| `CLOUD_RUN_SECRETS` | `DATABASE_URL=todoer-database-url:latest` | Secret Manager bindings |

> `CLOUD_RUN_SECRETS` is optional. If you leave it empty, no secrets are wired.

## 5) Merge to deploy

- **Develop branch** → automatic deploy to **staging**.
- **Main branch** → automatic deploy to **staging**, then **manual approval** for **production**.

The CD workflow:

1. Builds and pushes the Docker image to Artifact Registry.
2. Runs `npm run migrate` before deploy (currently a no-op placeholder).
3. Deploys to Cloud Run with `APP_VERSION` and `IMAGE_TAG` set.
4. Runs remote integration tests against the deployed service.

## 6) Integration tests on the deployed service

The workflow runs `npm run test:integration:remote` after deploy. It uses the service URL fetched from Cloud Run and validates `/healthz` and `/readiness`.

If `/readiness` is failing, ensure `DATABASE_URL` points at a reachable database and that your network rules allow access from Cloud Run.

## 7) Rollback procedure

If a deploy fails or is unhealthy:

```bash
# Find the previous revision
 gcloud run services list-revisions todoer-api-prod --region us-central1

# Roll traffic back to a known-good revision
 gcloud run services update-traffic todoer-api-prod \
   --region us-central1 \
   --to-revisions todoer-api-prod-00009-abc=100
```

## 8) Required runtime secrets

Currently supported runtime secrets (optional):

- `DATABASE_URL` (used by `/readiness` health check)

Add more secrets here as new configuration is introduced (e.g., SMS provider credentials).

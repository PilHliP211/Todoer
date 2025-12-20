# Deployment Guide

## Continuous Deployment (Cloud Run)

The CD pipeline is implemented via `.github/workflows/cd.yml` and uses GitHub Environments for
configuration.

### Required GitHub environment variables

Populate these from `infra/outputs/<env>.json` using `infra/scripts/bootstrap-github-env.sh`:

- `GCP_PROJECT_ID`
- `GCP_REGION`
- `GCP_ARTIFACT_REGISTRY_REPO`
- `GCP_ARTIFACT_REGISTRY_LOCATION`
- `CLOUD_RUN_SERVICE_NAME`
- `RUNTIME_SERVICE_ACCOUNT`

Required GitHub environment secrets:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_DEPLOYER_SERVICE_ACCOUNT`

Optional GitHub environment variables:

- `CLOUD_RUN_MIN_INSTANCES` (defaults to Cloud Run service config)
- `CLOUD_RUN_SECRETS` (format: `KEY=secret:version,OTHER=secret:version`)

### Pipeline behavior

- Push to `develop` or `main` builds a container image tagged with the commit SHA, pushes it to
  Artifact Registry, and deploys to Cloud Run staging.
- Push to `main` also triggers a production promotion job that requires manual approval via the
  `prod` GitHub environment and deploys the same image tag.
- Deploys set `COMMIT_SHA` and `IMAGE_TAG` environment variables on the Cloud Run revision.

## Rollback procedure

1. Identify the previous revision for the service:

   ```bash
   gcloud run revisions list \
     --project <project-id> \
     --region <region> \
     --service <service-name>
   ```

2. Shift traffic back to the previous healthy revision:

   ```bash
   gcloud run services update-traffic <service-name> \
     --project <project-id> \
     --region <region> \
     --to-revisions <previous-revision>=100
   ```

3. Verify `/healthz` returns 200 on the rolled-back service.

If necessary, re-run the CD pipeline with a known-good commit SHA to redeploy the image.

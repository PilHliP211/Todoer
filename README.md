# Todoer

ToDo app with reward system, SMS authentication and multitenancy on GCP.

## Getting Started

### 1) Install local tooling

- Node.js 20+ and npm
- Git
- Terraform >= 1.5
- Google Cloud SDK (`gcloud`)

Install Terraform via one of the official channels:

- Homebrew: `brew install terraform`
- `tfenv`: `tfenv install 1.6.6 && tfenv use 1.6.6`
- Direct download: https://developer.hashicorp.com/terraform/downloads

### 2) Clone and install dependencies

```bash
git clone <your-fork-or-repo-url>
cd Todoer
npm install
```

### 3) Create GCP projects

Create two GCP projects (recommended): one for staging and one for prod. Example IDs:

- `todoer-staging`
- `todoer-prod`

Also ensure billing is enabled for each project.

### 4) Authenticate locally to GCP

```bash
gcloud auth login
gcloud auth application-default login
```

Set the default project when working with a specific environment:

```bash
gcloud config set project todoer-staging
```

### 5) Bootstrap Terraform remote state buckets

Terraform state is stored in GCS. Create a bucket per environment before running the main
Terraform config.

```bash
terraform -chdir=infra/bootstrap init
terraform -chdir=infra/bootstrap apply \
  -var="project_id=todoer-staging" \
  -var="region=us-central1" \
  -var="state_bucket_name=todoer-tf-state-staging"
```

Repeat for prod with its own bucket name (for example, `todoer-tf-state-prod`).

### 6) Initialize Terraform backend

```bash
terraform -chdir=infra init -backend-config=backend/staging.hcl
```

### 7) Plan and apply infrastructure

```bash
terraform -chdir=infra plan -var-file=environments/staging.tfvars
terraform -chdir=infra apply -var-file=environments/staging.tfvars
```

### 8) Capture outputs for CD/local tooling

After apply, Terraform writes a canonical JSON file to:

```
infra/outputs/staging.json
```

Use this file to populate CI/CD environment variables and local `.env` files.

### 9) Run the API locally

```bash
npm run dev
```

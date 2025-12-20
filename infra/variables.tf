variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (staging/prod)"
  type        = string
}

variable "artifact_registry_repo" {
  description = "Artifact Registry repository ID"
  type        = string
  default     = "todoer"
}

variable "cloud_run_service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "todoer-api"
}

variable "runtime_service_account_name" {
  description = "Runtime service account name (without domain)"
  type        = string
  default     = "todoer-runtime"
}

variable "deployer_service_account_name" {
  description = "Deployer service account name (without domain)"
  type        = string
  default     = "todoer-deployer"
}

variable "enable_cloudsql_client" {
  description = "Grant Cloud SQL client role to runtime service account"
  type        = bool
  default     = false
}

variable "cloud_run_placeholder_image" {
  description = "Placeholder image for Cloud Run service"
  type        = string
  default     = "gcr.io/cloudrun/hello"
}

variable "github_repository" {
  description = "GitHub repository in OWNER/REPO format for OIDC conditions"
  type        = string
}

variable "github_branch" {
  description = "Optional branch to restrict OIDC access (e.g., main)"
  type        = string
  default     = ""
}

variable "github_workload_identity_pool_id" {
  description = "Workload Identity Pool ID for GitHub Actions"
  type        = string
  default     = "todoer-github"
}

variable "github_workload_identity_provider_id" {
  description = "Workload Identity Pool Provider ID for GitHub Actions"
  type        = string
  default     = "todoer-github"
}

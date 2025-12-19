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

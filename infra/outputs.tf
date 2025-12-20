output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "artifact_registry_repo" {
  value = google_artifact_registry_repository.docker.repository_id
}

output "cloud_run_service_name" {
  value = google_cloud_run_service.api.name
}

output "runtime_service_account_email" {
  value = google_service_account.runtime.email
}

output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}

output "deployer_service_account_email" {
  value = google_service_account.deployer.email
}

output "cd_config" {
  value = local.cd_config
}

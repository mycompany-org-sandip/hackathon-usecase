output "repository_id" {
  description = "Artifact Registry repository ID"
  value       = google_artifact_registry_repository.repo.repository_id
}

output "repository_location" {
  description = "Region where the Artifact Registry is created"
  value       = google_artifact_registry_repository.repo.location
}

output "repository_url" {
  description = "Full Docker repository URL"
  value       = "${google_artifact_registry_repository.repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}

output "repository_self_link" {
  description = "Self link of the repository"
  value       = google_artifact_registry_repository.repo.self_link
}

output "repository_id" {
  description = "Artifact Registry repository ID"
  value       = google_artifact_registry_repository.repo.repository_id
}

output "repository_location" {
  description = "Region of the Artifact Registry"
  value       = google_artifact_registry_repository_repository.repo.location
}

output "repository_url" {
  description = "Full Docker repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}

output "repository_self_link" {
  description = "Self link for the Artifact Registry repository"
  value       = google_artifact_registry_repository.repo.self_link
}

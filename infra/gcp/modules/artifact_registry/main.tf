resource "google_artifact_registry_repository" "repo" {
  provider               = google
  location               = var.region
  repository_id          = var.repo_name
  format                 = "DOCKER"
  description            = "Artifact registry for ${var.repo_name}"
}

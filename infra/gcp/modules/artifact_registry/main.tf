resource "google_artifact_registry_repository" "repo" {
  count         = 1
  provider      = google
  location      = var.artifact_region
  repository_id = var.repo_name
  format        = "DOCKER"
  description   = "Artifact registry for ${var.repo_name}"

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [description]
  }
}

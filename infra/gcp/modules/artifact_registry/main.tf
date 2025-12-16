# Check for existing repo
data "google_artifact_registry_repository" "existing" {
  provider      = google
  for_each      = { "repo" = var.repo_name }
  project       = var.project_id
  location      = var.region
  repository_id = each.value
}

resource "google_artifact_registry_repository" "repo" {
  count        = length(data.google_artifact_registry_repository.existing) == 0 ? 1 : 0
  provider     = google
  location     = var.region
  repository_id = var.repo_name
  format       = "DOCKER"
  description  = "Artifact registry for ${var.repo_name}"

  lifecycle {
    prevent_destroy = true
  }
}

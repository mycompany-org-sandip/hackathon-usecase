resource "google_storage_bucket" "tf_state" {
  name                        = var.bucket_name
  project                     = var.project_id
  location                    = var.location
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = true
  versioning { enabled = true }

  dynamic "retention_policy" {
    for_each = var.retention_days > 0 ? [1] : []
    content {
      retention_period = var.retention_days * 86400
      is_locked        = var.enable_object_lock
    }
  }

  lifecycle_rule {
    action { type = "Delete" }
    condition { age = 365 }
  }
  labels = merge(var.labels, { managed = "terraform", purpose = "state" })
}

# Bucket encryption with Google-managed key (can be switched to CMEK)
resource "google_storage_bucket_iam_binding" "admins" {
  bucket = google_storage_bucket.tf_state.name
  role   = "roles/storage.admin"
  members = [
    "projectOwner:${var.project_id}"
  ]
}

output "state_bucket_name" { value = google_storage_bucket.tf_state.name }

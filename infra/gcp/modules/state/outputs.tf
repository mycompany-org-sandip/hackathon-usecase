output "state_bucket_name" {
description = "The name of the GCS bucket used for Terraform state"
value       = google_storage_bucket.tf_state.name
}

output "state_bucket_self_link" {
description = "Self-link of the GCS bucket"
value       = google_storage_bucket.tf_state.self_link
}

output "state_bucket_url" {
description = "GS URL to access the bucket"
value       = "gs://${google_storage_bucket.tf_state.name}"
}

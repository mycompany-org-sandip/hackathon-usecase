// ...existing code...
resource "google_secret_manager_secret" "secrets" {
  for_each  = var.secrets
  secret_id = each.key
    replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
    }
  }
}
// ...existing code...
locals {
  iam_bindings = {
    for binding in flatten([
      for secret, members in var.access_bindings : [
        for member in members : {
          key    = "${secret}|${member}"
          secret = secret
          member = member
        }
      ]
    ]) : binding.key => binding
  }
}

// ...existing code...

resource "google_secret_manager_secret_iam_member" "members" {
  for_each = local.iam_bindings

  secret_id = google_secret_manager_secret.secrets[each.value.secret].id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value.member
}


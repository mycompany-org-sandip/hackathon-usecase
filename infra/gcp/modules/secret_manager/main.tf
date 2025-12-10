locals {
  project = var.project_id
}

# ------------------------------------------------------
# Create Secret Resources
# ------------------------------------------------------
resource "google_secret_manager_secret" "secrets" {
  for_each  = var.secrets
  project   = local.project
  secret_id = each.key

  replication {
    dynamic "auto" {
      for_each = each.value.replication.automatic ? [1] : []
      content {}
    }

    dynamic "user_managed" {
      for_each = each.value.replication.automatic ? [] : [1]
      content {
        dynamic "replicas" {
          for_each = try(each.value.replication.locations, [])
          content {
            location = replicas.value
          }
        }
      }
    }
  }

  labels = each.value.labels
}

# ------------------------------------------------------
# Create Secret Versions (only when initial_value exists)
# ------------------------------------------------------
resource "google_secret_manager_secret_version" "versions" {
  for_each = {
    for name, cfg in var.secrets :
    name => cfg
    if try(
      (
        cfg.initial_value != null
        && trim(cfg.initial_value) != ""
      ),
      false
    )
  }

  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value.initial_value
}

# ------------------------------------------------------
# IAM Bindings for Secret Access
# ------------------------------------------------------
resource "google_secret_manager_secret_iam_member" "members" {
  for_each = {
    for pair in flatten([
      for secret_name, members in var.access_bindings : [
        for member in members : {
          secret = secret_name
          member = member
        }
      ]
    ]) :
    "${pair.secret}|${pair.member}" => pair
  }

  project   = local.project
  secret_id = each.value.secret
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value.member

  depends_on = [google_secret_manager_secret.secrets]
}

data "google_secret_manager_secret" "existing" {
  for_each = var.secrets
  project  = var.project_id
  secret_id = each.key
}

resource "google_secret_manager_secret" "secrets" {
  for_each = { for k, v in var.secrets : k => v if lookup(data.google_secret_manager_secret.existing, k, null) == null }
  project   = var.project_id
  secret_id = each.key

  replication {
    auto {}
  }

  lifecycle { prevent_destroy = true }
}

# IAM bindings
locals {
  iam_bindings = {
    for pair in flatten([
      for secret, members in var.access_bindings : [
        for member in members : { key = "${secret}|${member}", secret = secret, member = member }
      ]
    ]) : pair.key => pair
  }
}

resource "google_secret_manager_secret_iam_member" "members" {
  for_each = local.iam_bindings
  project  = var.project_id
  secret_id = each.value.secret
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value.member
}

locals {
  project = var.project_id
}

resource "google_service_account" "accounts" {
  for_each     = var.service_accounts
  account_id   = each.key
  display_name = each.value.display_name
  project      = var.project_id
}

# Assign IAM Roles
resource "google_project_iam_member" "roles" {
  for_each = {
    for item in flatten([
      for sa_name, sa in var.service_accounts : [
        for role in sa.roles : {
          key     = "${sa_name}-${role}"
          sa_name = sa_name
          role    = role
        }
      ]
    ]) :
    item.key => {
      sa_name = item.sa_name
      role    = item.role
    }
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.accounts[each.value.sa_name].email}"
}


resource "google_project_iam_custom_role" "custom" {
  for_each    = var.custom_roles
  project     = local.project
  role_id     = each.key
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = "GA"
}

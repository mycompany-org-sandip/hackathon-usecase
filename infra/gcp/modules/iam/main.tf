locals {
  project = var.project_id
}

resource "google_service_account" "accounts" {
  for_each     = var.service_accounts
  account_id   = each.key
  display_name = each.value.display_name
  project      = var.project_id
}

resource "google_project_iam_member" "sa_roles_per_role" {
  for_each = toset(flatten([
    for sa_key, sa in var.service_accounts : [
      for role in sa.roles : "${sa_key}|${role}"
    ]
  ]))

  project = var.project_id
  role    = element(split("|", each.value), 1)
  member  = "serviceAccount:${google_service_account.accounts[element(split("|", each.value), 0)].email}"
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

output "service_account_emails" {
  description = "Map of service account IDs to their emails"
  value       = { for k, v in google_service_account.accounts : k => v.email }
}

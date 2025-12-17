variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "secrets" {
  description = "Secrets to manage as key -> secret_id"
  type        = map(string)
}

variable "access_bindings" {
  description = "IAM bindings for Secret Manager secrets"
  type        = map(list(string))
  default     = {}
}





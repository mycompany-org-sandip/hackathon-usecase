variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "secrets" {
  type = map(any)
}


variable "access_bindings" {
  description = "IAM bindings for Secret Manager secrets"
  type        = map(list(string))
  default     = {}
}

variable "app_runner_sa" {
  description = "Service account used by application runtime"
  type        = string
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
}

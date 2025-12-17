variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "secrets" {
  description = "Secrets to manage"
  type        = set(string)
}

variable "access_bindings" {
  description = "IAM bindings for each secret. secret_name => [members]"
  type        = map(list(string))
  default     = {}
}




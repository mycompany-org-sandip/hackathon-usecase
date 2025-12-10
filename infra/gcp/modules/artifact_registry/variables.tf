variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region where the repository will be created (e.g., asia-south1)"
  type        = string
}

variable "repo_name" {
  description = "Artifact Registry repository name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

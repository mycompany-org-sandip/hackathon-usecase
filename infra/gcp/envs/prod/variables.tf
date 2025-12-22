variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "repo_name" {
  description = "Artifact Registry repository name"
  type        = string
}

variable "artifact_region" {
  description = "Region for Artifact Registry"
  type        = string
  default     = "us-central1"
}


variable "public_subnet_names" {
  type    = list(string)
  default = []
}

variable "public_subnet_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "private_subnet_names" {
  type = list(string)
}

variable "private_subnet_cidr_blocks" {
  type = list(string)
}

variable "firewall_ssh_source_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "allow_http" {
  type    = bool
  default = true
}

variable "allow_https" {
  type    = bool
  default = true
}

variable "app_runner_sa" {
  description = "Service account used by applications"
  type        = string
}

variable "node_service_account" {
  type        = string
  description = "Service account for GKE nodes"
}

variable "deletion_protection" {
  description = "Protect GKE cluster from deletion"
  type        = bool
}
variable "secrets" {
  description = "Secrets to be created in Secret Manager"
  type        = map(string)
  default     = {}
}

variable "access_bindings" {
  description = "IAM bindings for secrets"
  type        = map(list(string))
  default     = {}
}

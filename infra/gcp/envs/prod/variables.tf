# -------------------------------
# General Project Variables
# -------------------------------

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
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "repo_name" {
  description = "Artifact Registry repository name"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block number for subnet addressing"
  type        = number   # ✅ FIXED
}

# -------------------------------
# Network Variables
# -------------------------------

variable "public_subnet_names" {
  description = "List of public subnet names"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidr_blocks" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "private_subnet_names" {
  description = "List of private subnet names"
  type        = list(string)
  # ✅ NO DEFAULT (must come from tfvars)
}

variable "private_subnet_cidr_blocks" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  # ✅ NO DEFAULT (must come from tfvars)
}

variable "firewall_ssh_source_ranges" {
  description = "Source ranges allowed for SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allow_http" {
  description = "Enable HTTP traffic"
  type        = bool
  default     = true
}

variable "allow_https" {
  description = "Enable HTTPS traffic"
  type        = bool
  default     = true
}

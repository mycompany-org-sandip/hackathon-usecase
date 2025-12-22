variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "GCP region for the cluster"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "network" {
  description = "Self-link of the VPC network"
  type        = string
}

variable "subnetwork" {
  description = "Self-link of the subnet for the cluster"
  type        = string
}


variable "node_service_account" {
  description = "Service account used by GKE nodes"
  type        = string
}

variable "deletion_protection" {
  description = "Whether to protect the cluster from deletion"
  type        = bool
  default     = true
}

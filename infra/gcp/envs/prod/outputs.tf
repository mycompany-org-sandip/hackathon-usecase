# ------------------------------
# VPC / Network Outputs
# ------------------------------

output "vpc_name" {
  description = "Name of the VPC"
  value       = module.network.vpc_name
}

output "vpc_self_link" {
  description = "Self-link of the VPC"
  value       = module.network.vpc_self_link
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.network.private_subnet_ids
}

output "private_subnet_self_links" {
  description = "Self-links of private subnets"
  value       = module.network.private_subnet_self_links
}

# ------------------------------
# GKE Cluster Outputs
# ------------------------------

output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = module.gke.endpoint
}

# SAFE FIX (IMPORTANT)
output "gke_cluster_master_auth" {
  description = "Master authentication info for the cluster"
  value       = module.gke.master_auth
  sensitive   = true
}

# ------------------------------
# Artifact Registry Outputs
# ------------------------------

output "artifact_registry_repo_id" {
  description = "ID of the Artifact Registry repository"
  value       = module.artifact_registry.repo_id
}

output "artifact_registry_repo_url" {
  description = "Repository URL for pushing images"
  value       = module.artifact_registry.repo_url
}

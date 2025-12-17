# ------------------------------

# VPC / Network Outputs

# ------------------------------

output "vpc_name" {
  description = "Name of the VPC"
  value       = module.network.network_name
}

output "vpc_self_link" {
  description = "Self-link of the VPC"
  value       = module.network.vpc_self_link
}

output "private_subnet_ids" {
  description = "Names of private subnets"
  value       = module.network.private_subnet_names
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

output "gke_cluster_master_auth" {
  description = "Master authentication info for the cluster"
  value       = module.gke.master_auth
}

# ------------------------------

# Artifact Registry Outputs

# ------------------------------

output "artifact_registry_repo_id" {
  description = "ID of the Artifact Registry repository"
  value       = module.artifact_registry.repository_id
}

output "artifact_registry_repo_url" {
  description = "Repository URL for pushing images"
  value       = module.artifact_registry.repository_url
}

output "vpc_self_link" {
  description = "Self link of the VPC"
  value       = google_compute_network.vpc.self_link
}

output "network_name" {
  description = "Name of the VPC"
  value       = google_compute_network.vpc.name
}

output "region" {
  description = "Region of the network"
  value       = var.region
}

output "private_subnet_self_links" {
  description = "Self links of private subnets"
  value       = [for s in google_compute_subnetwork.private : s.self_link]
}

output "private_subnet_names" {
  description = "Names of private subnets"
  value       = [for s in google_compute_subnetwork.private : s.name]
}

output "public_subnet_self_links" {
  description = "Self links of public subnets"
  value       = [for s in google_compute_subnetwork.public : s.self_link]
}

output "router_name" {
  description = "Cloud Router name"
  value       = google_compute_router.router.name
}

output "nat_name" {
  description = "Cloud NAT name"
  value       = google_compute_router_nat.nat.name
}

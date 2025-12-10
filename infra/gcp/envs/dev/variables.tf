variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-south1"
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "repo_name" {
  type = string
}

variable "cidr_block" {
  type = number
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

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "network_name" {
  type    = string
  default = "app-vpc"
}

variable "auto_create_subnetworks" {
  type    = bool
  default = false
}

variable "public_subnet_names" {
  type = list(string)
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
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


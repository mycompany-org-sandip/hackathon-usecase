variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "dns_prefix" { type = string }
variable "vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}
variable "node_count" {
  type    = number
  default = 2
}
variable "subnet_id" { type = string }
variable "service_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "dns_service_ip" {
  type    = string
  default = "10.0.0.10"
}
variable "docker_bridge_cidr" {
  type    = string
  default = "172.17.0.1/16"
}
variable "log_analytics_workspace_id" { type = string }
variable "acr_id" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

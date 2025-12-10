variable "subscription_id" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "location" {
  type    = string
  default = "eastus"
}
variable "vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}
variable "node_count" {
  type    = number
  default = 3
}

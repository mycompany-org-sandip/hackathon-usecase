variable "custom_roles" {
  type = map(object({
    title       = string
    description = string
    permissions = list(string)
  }))
  default = {}
}

variable "project_id" {
  type = string
}

variable "service_accounts" {
  type = map(object({
    display_name = string
    roles        = list(string)
  }))
  default = {}
}

















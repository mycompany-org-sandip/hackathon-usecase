variable "project_id" {
  type = string
}

variable "location" {
  type    = string
  default = "US"
}

variable "bucket_name" {
  type = string
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "retention_days" {
  type    = number
  default = 0
}

variable "enable_object_lock" {
  type    = bool
  default = false
}

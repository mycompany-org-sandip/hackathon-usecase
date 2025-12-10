variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "secrets" {
  description = "Map of secrets to create with replication and initial values"
  type = map(object({
    replication = object({
      automatic = bool
      locations = optional(list(string), [])
    })
    initial_value = optional(string, "")
    labels        = optional(map(string), {})
  }))
}

variable "access_bindings" {
  description = "IAM bindings for each secret. secret_name => [members]"
  type        = map(list(string))
}

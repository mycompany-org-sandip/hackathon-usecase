terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
  backend "gcs" {
    bucket = "tf-state-prod-example"
    prefix = "env/prod"
  }
}

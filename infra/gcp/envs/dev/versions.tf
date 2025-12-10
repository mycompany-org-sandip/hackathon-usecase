terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
  backend "gcs" {
    bucket = "tf-state-dev-example" # ensure bucket exists (apply state module separately first)
    prefix = "env/dev"              # path within bucket
  }
}

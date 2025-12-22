terraform {
  backend "gcs" {
    bucket  = "tf-state-massive-sandbox-477717-k3-prod"
    prefix  = "gcp/prod"
  }
}


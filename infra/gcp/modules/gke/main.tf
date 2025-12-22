

resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  network    = var.network
  subnetwork = var.subnetwork

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = var.deletion_protection

  node_config {
    service_account = "compute@${var.project_id}.iam.gserviceaccount.com"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  lifecycle {
    ignore_changes = [
      remove_default_node_pool,
      initial_node_count,
    ]
  }
}

resource "google_container_node_pool" "primary" {
  name     = "primary-pool"
  cluster  = google_container_cluster.gke.name
  location = var.region
  project  = var.project_id

  node_count = var.node_count

  node_config {
    service_account = "compute@${var.project_id}.iam.gserviceaccount.com"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }

  depends_on = [
    google_container_cluster.gke
  ]
}



 
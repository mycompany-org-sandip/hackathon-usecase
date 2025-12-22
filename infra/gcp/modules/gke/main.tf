resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id
   

  network    = var.network
  subnetwork = var.subnetwork

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = var.deletion_protection

  lifecycle {
    ignore_changes = [
      # Prevent provider from attempting to update the removed default node pool
      remove_default_node_pool,
      # Only used at creation time; ignoring avoids spurious updates
      initial_node_count,
    ]
  }


  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}



resource "google_container_node_pool" "primary" {
  name       = "primary-pool"
  cluster    = google_container_cluster.gke.name
  location   = google_container_cluster.gke.location
  project    = var.project_id

  node_count = 1

  node_config {
    machine_type    = "e2-medium"
    service_account = var.node_service_account

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    boot_disk {
      disk_type = "pd-standard"
      size_gb   = 20
    }
  }
}

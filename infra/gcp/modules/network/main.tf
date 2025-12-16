resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-${var.network_name}"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  description             = "Primary VPC for ${var.environment} workloads"
}

resource "google_compute_subnetwork" "public" {
  count                    = length(var.public_subnet_cidr_blocks)
  name                     = "${var.public_subnet_names[count.index]}-${var.environment}"
  ip_cidr_range            = var.public_subnet_cidr_blocks[count.index]
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  project                  = var.project_id
}

resource "google_compute_subnetwork" "private" {
  count         = length(var.private_subnet_cidr_blocks)
  name          = "${var.private_subnet_names[count.index]}-${var.environment}"
  ip_cidr_range = var.private_subnet_cidr_blocks[count.index]
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

resource "google_compute_firewall" "internal" {
  name    = "${var.network_name}-${var.environment}-allow-internal"
  network = google_compute_network.vpc.self_link
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = concat(var.public_subnet_cidr_blocks, var.private_subnet_cidr_blocks)
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.network_name}-${var.environment}-allow-ssh"
  network = google_compute_network.vpc.self_link
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.firewall_ssh_source_ranges
}

resource "google_compute_firewall" "http" {
  count   = var.allow_http ? 1 : 0
  name    = "${var.network_name}-${var.environment}-allow-http"
  network = google_compute_network.vpc.self_link
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}

resource "google_compute_firewall" "https" {
  count   = var.allow_https ? 1 : 0
  name    = "${var.network_name}-${var.environment}-allow-https"
  network = google_compute_network.vpc.self_link
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https"]
}

resource "google_compute_router" "router" {
  name    = "${var.network_name}-${var.environment}-router"
  project = var.project_id
  network = google_compute_network.vpc.self_link
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-${var.environment}-nat"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  dynamic "subnetwork" {
    for_each = google_compute_subnetwork.private
    content {
      name                    = subnetwork.value.id
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

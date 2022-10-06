resource "google_container_cluster" "default" {
  name     = "${var.project_id}-gke"
  location = var.region
  
  initial_node_count       = 2

 ip_allocation_policy {
    cluster_ipv4_cidr_block       = "10.104.0.0/14"
    services_ipv4_cidr_block      = "10.108.0.0/20"
}

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}
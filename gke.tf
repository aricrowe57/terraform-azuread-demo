resource "google_container_cluster" "default" {
  name     = "${var.project_id}-gke"
  location = var.region
  
  initial_node_count       = 2

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}
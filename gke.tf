resource "google_container_cluster" "default" {
  name     = "${var.project_id}-gke"
  location = var.region
  
  initial_node_count       = 2

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/owner"
  member  = "group:hashiConfDemoOpsTeam@hashiconf-entra-demo.app"  ##Note: This needs to be replaced to reference the display name of the group created in AAD
}
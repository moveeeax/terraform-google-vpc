resource "google_compute_network" "this" {
  project                         = var.project_id
  name                            = var.name
  description                     = var.description
  routing_mode                    = var.routing_mode
  auto_create_subnetworks         = var.auto_create_subnetworks
  mtu                             = var.mtu
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

# Enabling the host project is a project-level setting, but it only makes sense for the
# project that owns this network, so it is managed here rather than by the caller.
resource "google_compute_shared_vpc_host_project" "this" {
  count = var.shared_vpc_host ? 1 : 0

  project = var.project_id

  # Create after the network and remove before it, so the host flag never outlives the
  # network this module exists to share.
  depends_on = [google_compute_network.this]
}

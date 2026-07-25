# Test-only requirement: mock_provider needs Terraform >= 1.7 (or OpenTofu >= 1.7).
# The module itself still supports >= 1.5 -- do not bump required_version for these tests.
mock_provider "google" {}

variables {
  project_id = "example-project"
  name       = "example-vpc"
}

run "defaults_are_safe" {
  command = plan

  assert {
    condition     = google_compute_network.this.auto_create_subnetworks == false
    error_message = "The network must default to custom subnet mode. Auto mode creates a subnet in every region across 10.128.0.0/9."
  }

  assert {
    condition     = google_compute_network.this.routing_mode == "REGIONAL"
    error_message = "routing_mode must default to REGIONAL."
  }

  assert {
    condition     = google_compute_network.this.delete_default_routes_on_create == false
    error_message = "delete_default_routes_on_create must default to false so the network keeps working internet egress unless the caller opts out."
  }

  assert {
    condition     = google_compute_network.this.mtu == 1460
    error_message = "mtu must default to 1460."
  }

  assert {
    condition     = google_compute_network.this.project == "example-project"
    error_message = "project must come from var.project_id rather than the provider default."
  }

  assert {
    condition     = google_compute_network.this.name == "example-vpc"
    error_message = "name must be passed through to the network."
  }
}

run "overrides_are_passed_through" {
  command = plan

  variables {
    routing_mode                    = "GLOBAL"
    auto_create_subnetworks         = true
    delete_default_routes_on_create = true
    mtu                             = 8896
    description                     = "managed by terraform"
  }

  assert {
    condition     = google_compute_network.this.routing_mode == "GLOBAL"
    error_message = "routing_mode override was not applied."
  }

  assert {
    condition     = google_compute_network.this.auto_create_subnetworks == true
    error_message = "auto_create_subnetworks override was not applied."
  }

  assert {
    condition     = google_compute_network.this.delete_default_routes_on_create == true
    error_message = "delete_default_routes_on_create override was not applied."
  }

  assert {
    condition     = google_compute_network.this.mtu == 8896
    error_message = "mtu override was not applied."
  }

  assert {
    condition     = google_compute_network.this.description == "managed by terraform"
    error_message = "description override was not applied."
  }
}

# Test-only requirement: mock_provider needs Terraform >= 1.7 (or OpenTofu >= 1.7).
mock_provider "google" {}

variables {
  project_id = "host-project"
  name       = "shared-vpc"
}

run "shared_vpc_host_is_off_by_default" {
  command = plan

  assert {
    condition     = length(google_compute_shared_vpc_host_project.this) == 0
    error_message = "The module must not enable the project as a Shared VPC host unless shared_vpc_host is true."
  }

  assert {
    condition     = output.shared_vpc_host == null
    error_message = "shared_vpc_host output must be null when hosting is disabled."
  }
}

run "shared_vpc_host_enables_the_network_project" {
  command = plan

  variables {
    shared_vpc_host = true
  }

  assert {
    condition     = length(google_compute_shared_vpc_host_project.this) == 1
    error_message = "shared_vpc_host = true must create exactly one google_compute_shared_vpc_host_project."
  }

  assert {
    condition     = google_compute_shared_vpc_host_project.this[0].project == "host-project"
    error_message = "The host project must be var.project_id, the project that owns the network."
  }

  assert {
    condition     = output.shared_vpc_host == "host-project"
    error_message = "shared_vpc_host output must expose the host project ID."
  }
}

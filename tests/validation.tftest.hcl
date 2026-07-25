# Test-only requirement: mock_provider needs Terraform >= 1.7 (or OpenTofu >= 1.7).
mock_provider "google" {}

variables {
  project_id = "example-project"
  name       = "example-vpc"
}

run "accepts_minimal_valid_name" {
  command = plan

  variables {
    name = "a"
  }

  assert {
    condition     = google_compute_network.this.name == "a"
    error_message = "A single lowercase letter is a valid RFC1035 name and must be accepted."
  }
}

run "rejects_uppercase_name" {
  command = plan

  variables {
    name = "Prod-VPC"
  }

  expect_failures = [var.name]
}

run "rejects_name_starting_with_digit" {
  command = plan

  variables {
    name = "1-prod-vpc"
  }

  expect_failures = [var.name]
}

run "rejects_name_with_trailing_dash" {
  command = plan

  variables {
    name = "prod-vpc-"
  }

  expect_failures = [var.name]
}

run "rejects_name_with_underscore" {
  command = plan

  variables {
    name = "prod_vpc"
  }

  expect_failures = [var.name]
}

run "rejects_name_longer_than_63_characters" {
  command = plan

  variables {
    # 64 characters: one over the RFC1035 limit.
    name = "a0123456789012345678901234567890123456789012345678901234567890123"
  }

  expect_failures = [var.name]
}

run "rejects_empty_name" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [var.name]
}

run "rejects_invalid_routing_mode" {
  command = plan

  variables {
    routing_mode = "NotAValidValue"
  }

  expect_failures = [var.routing_mode]
}

run "rejects_lowercase_routing_mode" {
  command = plan

  variables {
    routing_mode = "global"
  }

  expect_failures = [var.routing_mode]
}

run "rejects_mtu_below_minimum" {
  command = plan

  variables {
    mtu = 1299
  }

  expect_failures = [var.mtu]
}

run "rejects_mtu_above_maximum" {
  command = plan

  variables {
    mtu = 8897
  }

  expect_failures = [var.mtu]
}

run "rejects_fractional_mtu" {
  command = plan

  variables {
    mtu = 1500.5
  }

  expect_failures = [var.mtu]
}

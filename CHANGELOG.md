# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the module uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.2.0] - 2026-11-07

### Added

- `shared_vpc_host` input (default `false`) that enables `project_id` as a Shared VPC host
  project via `google_compute_shared_vpc_host_project`, and a `shared_vpc_host` output
  with the host project ID (`null` when disabled). ([#3](https://github.com/moveeeax/terraform-google-vpc/issues/3))

[Unreleased]: https://github.com/moveeeax/terraform-google-vpc/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/moveeeax/terraform-google-vpc/compare/v1.1.0...v1.2.0

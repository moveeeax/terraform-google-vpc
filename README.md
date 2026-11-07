# terraform-google-vpc

Terraform module that manages a [Google Cloud](https://cloud.google.com/)
VPC network (`google_compute_network`). It creates a single custom-mode network
and exposes its self link so companion modules (subnets, firewall, routers) can
build on top of it.

## Usage

```hcl
module "vpc" {
  source = "github.com/moveeeax/terraform-google-vpc?ref=v1.0.0"

  project_id              = var.project_id
  name                    = "prod-vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}
```

A runnable example lives in [`examples/basic`](examples/basic).

### Shared VPC host

Set `shared_vpc_host = true` to enable `project_id` as a Shared VPC host project
(`google_compute_shared_vpc_host_project`). The `shared_vpc_host` output returns the host
project ID, so service-project attachments can depend on it.

```hcl
module "vpc" {
  source = "github.com/moveeeax/terraform-google-vpc?ref=v1.0.0"

  project_id      = var.host_project_id
  name            = "shared-vpc"
  shared_vpc_host = true
}
```

Hosting is a project-level setting: every network in the project becomes shareable, not
only this one. Service projects must be detached before the host flag can be removed. If
another configuration already enables the host project, leave this `false` so the two do
not fight over the same setting.

## Scope

This module manages the network object only. Subnets — and therefore VPC flow logs,
Private Google Access and subnet CIDR ranges — are managed by the companion
[`terraform-google-subnets`](https://github.com/moveeeax/terraform-google-subnets)
module, and firewall rules by
[`terraform-google-firewall`](https://github.com/moveeeax/terraform-google-firewall).
Feed `self_link` from this module into those.

## Notes on two easy mistakes

**`auto_create_subnetworks`** defaults to `false` and should stay there. Setting it to
`true` puts the network in *auto subnet mode*, which allocates a subnet in every current
and future GCP region out of `10.128.0.0/9`. Those ranges frequently collide with
on-premises or peered networks, and switching back to custom mode requires recreating the
network.

**`delete_default_routes_on_create`** applies at creation time only — flipping it on an
existing network does not add or remove routes. When `true`, the network is left with no
internet egress and no route to Google APIs until you add your own (for example a route to
the Private Google Access VIP), so only enable it when you manage egress routing
explicitly.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| google    | >= 5.0   |

## Inputs

| Name                              | Description                                                          | Type     | Default      | Required |
|-----------------------------------|----------------------------------------------------------------------|----------|--------------|:--------:|
| `project_id`                      | ID of the project in which to create the VPC network.                | `string` | n/a          |   yes    |
| `name`                            | Name of the VPC network. Must be a valid RFC1035 name.               | `string` | n/a          |   yes    |
| `routing_mode`                    | Network-wide routing mode: REGIONAL or GLOBAL.                       | `string` | `"REGIONAL"` |    no    |
| `auto_create_subnetworks`         | Create a subnetwork in every region automatically. Keep `false`.    | `bool`   | `false`      |    no    |
| `mtu`                             | Maximum transmission unit in bytes, between 1300 and 8896.          | `number` | `1460`       |    no    |
| `delete_default_routes_on_create` | Delete the default 0.0.0.0/0 routes at creation time only.          | `bool`   | `false`      |    no    |
| `description`                     | Optional description for the VPC network.                           | `string` | `null`       |    no    |
| `shared_vpc_host`                 | Enable `project_id` as a Shared VPC host project.                    | `bool`   | `false`      |    no    |

## Outputs

| Name           | Description                                              |
|----------------|----------------------------------------------------------|
| `id`           | Identifier of the VPC network.                          |
| `self_link`    | URI of the VPC network.                                 |
| `name`         | Name of the VPC network.                                |
| `gateway_ipv4` | IPv4 address of the gateway of the default route.       |
| `shared_vpc_host` | Host project ID when `shared_vpc_host` is true, otherwise `null`. |

## Development

```sh
terraform fmt -recursive
terraform init -backend=false
terraform validate
terraform test    # requires Terraform >= 1.7 for mock_provider
tflint --init && tflint
```

The suite in [`tests/`](tests) uses a mocked provider, so it needs no GCP credentials and
makes no API calls. It pins the safe defaults and the input validation rules. Note that
`terraform test` needs Terraform >= 1.7 for `mock_provider`; the module itself still
supports >= 1.5.

## License

[MIT](LICENSE)

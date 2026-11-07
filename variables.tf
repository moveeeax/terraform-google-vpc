variable "project_id" {
  description = "ID of the project in which to create the VPC network."
  type        = string
}

variable "name" {
  description = "Name of the VPC network. Must be a valid RFC1035 resource name."
  type        = string

  validation {
    condition     = can(regex("^[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?$", var.name))
    error_message = "name must be 1-63 characters and comply with RFC1035: start with a lowercase letter, contain only lowercase letters, digits and dashes, and not end with a dash."
  }
}

variable "routing_mode" {
  description = "Network-wide routing mode: REGIONAL or GLOBAL."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "routing_mode must be either REGIONAL or GLOBAL."
  }
}

variable "auto_create_subnetworks" {
  description = <<-EOT
    Whether to create a subnetwork in every region automatically ("auto subnet mode").
    Keep this false. Auto mode carves 10.128.0.0/9 across every current and future GCP
    region, which routinely collides with on-premises or peered ranges and cannot be
    reverted without recreating the network. Manage subnets explicitly instead.
  EOT
  type        = bool
  default     = false
}

variable "mtu" {
  description = "Maximum transmission unit in bytes for the network, between 1300 and 8896."
  type        = number
  default     = 1460

  validation {
    condition     = var.mtu >= 1300 && var.mtu <= 8896
    error_message = "mtu must be between 1300 and 8896."
  }

  validation {
    condition     = var.mtu == floor(var.mtu)
    error_message = "mtu must be a whole number of bytes."
  }
}

variable "delete_default_routes_on_create" {
  description = <<-EOT
    Whether to delete the default 0.0.0.0/0 routes to the internet gateway immediately
    after the network is created. This applies at creation time only -- toggling it on an
    existing network does not add or remove routes. Enabling it leaves the network with no
    internet egress and no route to Google APIs until you supply your own (for example a
    route to the Private Google Access VIP), so only set it true when you manage egress
    routing explicitly.
  EOT
  type        = bool
  default     = false
}

variable "description" {
  description = "Optional description for the VPC network."
  type        = string
  default     = null
}

variable "shared_vpc_host" {
  description = <<-EOT
    Whether to enable var.project_id as a Shared VPC host project. Hosting is a property
    of the whole project, not of this network: every network in the project becomes
    shareable, and service projects must be detached before it can be disabled. Leave
    false if another configuration already manages the host project.
  EOT
  type        = bool
  default     = false
}

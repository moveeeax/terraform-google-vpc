output "id" {
  description = "Identifier of the VPC network."
  value       = google_compute_network.this.id
}

output "self_link" {
  description = "URI of the VPC network."
  value       = google_compute_network.this.self_link
}

output "name" {
  description = "Name of the VPC network."
  value       = google_compute_network.this.name
}

output "gateway_ipv4" {
  description = "IPv4 address of the gateway of the default network route."
  value       = google_compute_network.this.gateway_ipv4
}

output "shared_vpc_host" {
  description = "Project ID enabled as a Shared VPC host project, or null when shared_vpc_host is false."
  value       = one(google_compute_shared_vpc_host_project.this[*].project)
}


output "vpc_name" {
  description = "The name of the VPC being created."
  value       = module.vpc_host.name
}

output "vpc_id" {
  description = "The name of the VPC being created."
  value       = module.vpc_host.id
}
output "vpc_self_link" {
  description = "The URI of the VPC being created."
  value       = module.vpc_host.self_link
}

output "subnets_psc" {
  description = "Private Service Connect subnet resources."
  value       = module.vpc_host.subnets_psc
}

output "vpc_project" {
  description = "Project where vpc is deployed"
  value       = module.vpc_host.project_id
}

output "vpc_subnet_links" {
  description = "Map of subnet self links keyed by name."
  value       = module.vpc_host.subnet_self_links
}

output "subnet_secondary_ranges" {
  description = "Map of subnet secondary ranges keyed by name."
  value       = module.vpc_host.subnet_secondary_ranges
}

output "cloud_router_name" {
  description = "Name of create Cloud router"
  value       = [for s in module.nat : s.router_name]
}

output "subnets_proxy_only" {
  description = "L7 ILB or L7 Regional LB subnet resources."
  value       = module.vpc_host.subnets_proxy_only
}

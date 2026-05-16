# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "nat_gateway_ips" {
  description = "Elastic IPs of NAT Gateways"
  value       = module.vpc.nat_gateway_ips
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

# RDS Outputs
output "db_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "db_name" {
  description = "Database name"
  value       = module.rds.db_name
}

output "db_secret_name" {
  description = "Name of database credentials secret in Secrets Manager"
  value       = module.secrets.db_secret_name
}

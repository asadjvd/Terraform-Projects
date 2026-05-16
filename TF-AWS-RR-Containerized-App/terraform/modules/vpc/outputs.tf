output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.custom_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value = {
    for k, s in aws_subnet.public : k => s.id
  }
}

output "webapp_subnet_ids" {
  description = "List of Web Subnet IDs"
  value = {
    for k, s in aws_subnet.webapp : k => s.id
  }
}

output "database_subnet_ids" {
  description = "List of Database Subnet IDs"
  value = {
    for k, s in aws_subnet.database : k => s.id
  }
}

output "nat_gateway_ips" {
  description = "Elastic IPs of NAT Gateways"
  value = {
    for k, eip in aws_eip.nat : k => eip.public_ip
  }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}
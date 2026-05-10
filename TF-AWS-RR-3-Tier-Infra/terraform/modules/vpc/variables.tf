variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "availability_zones" {
  description = "Map of availability zones"
  type        = map(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR block for public subnets"
  type        = map(string)
}

variable "web_subnet_cidrs" {
  description = "CIDR block for web subnets"
  type        = map(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR block for database subnets"
  type        = map(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT GW for all private subnets for cost optimization"
  type        = bool
  default     = true
}

variable "nat_gateway_subnet_mapping" {
  type = map(string)
}

variable "subnet_az_mapping" {
  type = map(string)
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

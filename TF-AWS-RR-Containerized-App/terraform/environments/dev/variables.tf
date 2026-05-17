variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ritual-roast"
}

# Network
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = map(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnet"
  type        = map(string)
}

variable "webapp_subnet_cidrs" {
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

variable "subnet_az_mapping" {
  type = map(string)
}

# Tags
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

# RDS 
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.4.7"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "recipedb"
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_multi_az" {
  description = "Enable RDS Multi-AZ"
  type        = bool
  default     = false
}

variable "db_backup_retention" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 7
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot on destroy"
  type        = bool
  default     = true
}

# ECR
variable "frontend_repo_name" {
  type = string
}

variable "backend_repo_name" {
  type = string
}

# EC2 Instance
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "frontend" {
  description = "NextJS frontend app repo name in ECR"
  type        = string
}

variable "backend" {
  description = "Flask backend app repo name in ECR"
  type        = string
}

variable "frontend_url" {
  description = "Github repo URL for NextJS frontend app"
  type        = string
}

variable "backend_url" {
  description = "Github repo URL for Flask backend app"
  type        = string
}
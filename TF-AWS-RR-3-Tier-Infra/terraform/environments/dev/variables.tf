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

variable "subnet_az_mapping" {
  type = map(string)
}

# Tags
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

# S3 Bucket
variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "bucket_suffix" {
  type = number
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
  default     = "ritualroastdb"
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

# SSH
variable "ssh_key_name" {
  description = "SSH key pair name for EC2 instances"
  type        = string
}

# Frontend ASG
variable "webapp_instance_type" {
  description = "Webapp instance type"
  type        = string
  default     = "t3.micro"
}

variable "webapp_min_size" {
  description = "Webapp ASG minimum size"
  type        = number
  default     = 2
}

variable "webapp_max_size" {
  description = "Webapp ASG maximum size"
  type        = number
  default     = 4
}

variable "webapp_desired_capacity" {
  description = "Webapp ASG desired capacity"
  type        = number
  default     = 2
}

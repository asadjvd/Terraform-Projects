# VPC Module

This module creates a complete 3-tier VPC infrastructure for the Ritual Roast application.

## Architecture

### Subnets
- **Public Subnets**: Internet-facing resources (ALB, NAT Gateways)
- **Frontend Subnets (Web Tier)**: Flask application servers
- **Database Subnets (Data Tier)**: MySQL RDS instances (completely isolated)

### Routing
- Public subnets route to Internet Gateway
- Web subnets route to NAT Gateway for outbound internet access
- Database subnets have no internet access (isolated)

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment        = "dev"
  project            = "ritual-roast"
  vpc_cidr           = "10.16.0.0/16"

  availability_zones = {
    az-1a = "us-east-1a"
    az-1b = "us-east-1b"
  }

  public_subnet_cidrs = {
    public-subnet-1a = "10.16.0.0/20"
    public-subnet-1b = "10.16.16.0/20"
  }

  web_subnet_cidrs = {
    web-subnet-1a = "10.16.64.0/20"
    web-subnet-1b = "10.16.80.0/20"
  }

  database_subnet_cidrs = {
    db-subnet-1a = "10.16.192.0/20"
    db-subnet-1b = "10.16.208.0/20"
  }

  subnet_az_mapping = {
    public-subnet-1a = "us-east-1a"
    public-subnet-1b = "us-east-1b"

    web-subnet-1a = "us-east-1a"
    web-subnet-1b = "us-east-1b"

    db-subnet-1a = "us-east-1a"
    db-subnet-1b = "us-east-1b"
  }

  enable_nat_gateway  = true
  single_nat_gateway  = true  # Set to false for multi-AZ NAT (higher cost)

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_cidr | CIDR block for VPC | string | "10.16.0.0/16" | no |
| environment | Environment name | string | - | yes |
| project | Project name | string | - | yes |
| availability_zones | Map of AZs | map(string) | - | yes |
| public_subnet_cidrs | Public subnet CIDRs | map(string) | - | yes |
| web_subnet_cidrs | Frontend subnet CIDRs | map(string) | - | yes |
| database_subnet_cidrs | Database subnet CIDRs | map(string) | - | yes |
| enable_nat_gateway | Enable NAT Gateway | bool | true | no |
| single_nat_gateway | Use single NAT Gateway | bool | false | no |
| tags | Common tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| vpc_cidr | VPC CIDR block |
| public_subnet_ids | Public subnet IDs |
| web_subnet_ids | Web subnet IDs |
| database_subnet_ids | Database subnet IDs |
| nat_gateway_ips | NAT Gateway Elastic IPs |
| internet_gateway_id | Internet Gateway ID |

## Cost Optimization

For development environments, consider:
- Setting `single_nat_gateway = true` to save ~$32/month
- Disabling NAT Gateway entirely if outbound internet access is not needed

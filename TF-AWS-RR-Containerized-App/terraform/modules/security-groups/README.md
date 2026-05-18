# Security Groups Module

This module creates all security groups for the 3-tier Ritual Roast application with proper network isolation.

## Security Architecture

### Traffic Flow
```
Internet → ALB SG (80) → WebApp SG (3000 & 5000) → RDS SG (3306)
```

### Security Groups

1. **ALB Security Group**
   - Ingress: HTTP (80) from internet
   - Egress: All traffic
   - Purpose: Public-facing load balancer

2. **Web Security Group**
   - Ingress: Port 5000 from ALB SG
   - Ingress: Port 3000 from ALB SG
   - Egress: All traffic
   - Purpose: Flask and NextJS applications

3. **RDS Security Group**
   - Ingress: MySQL (3306) from Web SG and its own SG
   - Egress: None (completely isolated)
   - Purpose: Database isolation

## Usage

```hcl
module "security_groups" {
  source = "../../modules/security-groups"

  environment        = "dev"
  project            = "ritual-roast"
  vpc_id             = module.vpc.vpc_id

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | string | - | yes |
| project | Project name | string | - | yes |
| vpc_id | VPC ID | string | - | yes |
| tags | Common tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_sg_id | ALB security group ID |
| web_sg_id | Frontend security group ID |
| database_sg_id | RDS security group ID |

✅ **Implemented**:
- Principle of least privilege
- Security group chaining (not CIDR blocks)
- Complete database isolation
- No SSH keys needed with Session Manager

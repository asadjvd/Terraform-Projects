# Ritual Roast - 3-Tier AWS Infrastructure

Highly available 3-tier application: Flask web application, MySQL database.

## Quick Deployment

### 1. Configure Terraform

```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

**Required Configuration:**
```hcl
region      = "us-east-1"
environment = "dev"
project     = "ritual-roast"

ssh_key_name     = "YOUR_KEY_NAME"

# High Availability (optional)
single_nat_gateway = false  # true = cost optimized, false = HA
db_multi_az        = true   # true = HA, false = cost optimized
```

### 3. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

**Deployment Time:** ~15-20 minutes

### 4. Access Application

```bash
# Get application URL
terraform output application_url
```

## Architecture

**Deployed Resources:**
- VPC with 6 subnets across 2 AZs (public, web, database)
- Public ALB for internet traffic
- Auto Scaling Groups (Web: 2-4)
- RDS MySQL (Multi-AZ optional)
- NAT Gateway (1 or 2 for HA)
- Secrets Manager for credentials
- S3 Bucket to download Flask application code during bootstrapping 
- CloudWatch for logging

## Cleanup

```bash
terraform destroy -auto-approve
```
---


**Stack:** Terraform | AWS | Python | MySQL

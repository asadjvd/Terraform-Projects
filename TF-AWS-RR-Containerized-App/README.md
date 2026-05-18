# ☕ Ritual Roast - Containerized 3-Tier AWS Infrastructure

Highly available containerized 3-tier application: Next.js frontend, Flask backend, MySQL database.

---

# Quick Deployment

## 1. Download Applications

```bash
curl -L -o ritual-roast-flask-backend.zip https://raw.githubusercontent.com/asadjvd/AWS-Projects/main/Ritual-Roast-Containerized-Application/Resources/ritual-roast-flask-backend.zip 
curl -L -o ritual-roast-nextjs-frontend.zip https://raw.githubusercontent.com/asadjvd/AWS-Projects/main/Ritual-Roast-Containerized-Application/Resources/ritual-roast-nextjs-frontend.zip

unzip ritual-roast-flask-backend.zip
unzip ritual-roast-nextjs-frontend.zip
```

## 2. Build and Push Docker Images

### Login to ECR

```bash
aws ecr get-login-password --region <YOUR_REGION> | \
docker login --username AWS --password-stdin \
"<YOUR_ACCOUNT_ID>.dkr.ecr.<YOUR_REGION>.amazonaws.com"
```

### Build & Push Next.js Frontend

```bash
cd ritual-roast-nextjs-frontend

docker build -t ritual-roast-nextjs-app:latest .

docker tag ritual-roast-nextjs-app:latest \
"<YOUR_ACCOUNT_ID>.dkr.ecr.<YOUR_REGION>.amazonaws.com/ritual-roast-nextjs-app:latest"

docker push \
"<YOUR_ACCOUNT_ID>.dkr.ecr.<YOUR_REGION>.amazonaws.com/ritual-roast-nextjs-app:latest"
```

### Build & Push Flask Backend

```bash
cd ritual-roast-flask-backend

docker build -t ritual-roast-flask-app:latest .

docker tag ritual-roast-flask-app:latest \
"<YOUR_ACCOUNT_ID>.dkr.ecr.<YOUR_REGION>.amazonaws.com/ritual-roast-flask-app:latest"

docker push \
"<YOUR_ACCOUNT_ID>.dkr.ecr.<YOUR_REGION>.amazonaws.com/ritual-roast-flask-app:latest"
```

---

# 3. Configure Terraform

```bash
cd terraform/environments/dev

cp terraform.tfvars.example terraform.tfvars

nano terraform.tfvars
```

## Required Configuration

```hcl
region      = "us-east-1"
environment = "dev"
project     = "ritual-roast"

# ECR Configuration
frontend_repo_name = "ritual-roast-nextjs-app"
backend_repo_name  = "ritual-roast-flask-app"

# EC2 Configuration
frontend      = "ritual-roast-nextjs-frontend"
backend       = "ritual-roast-flask-backend"
frontend_url  = "https://raw.githubusercontent.com/asadjvd/AWS-Projects/main/Ritual-Roast-Containerized-Application/Resources/ritual-roast-nextjs-frontend.zip"
backend_url   = "https://raw.githubusercontent.com/asadjvd/AWS-Projects/main/Ritual-Roast-Containerized-Application/Resources/ritual-roast-flask-backend.zip"


# High Availability (optional)
single_nat_gateway = false  # true = cost optimized, false = HA
db_multi_az        = true   # true = HA, false = cost optimized
```

---

# 4. Deploy Infrastructure

```bash
terraform init

terraform plan

terraform apply -auto-approve
```

Deployment Time: ~15-20 minutes

---

# Architecture Overview

## Deployed Resources

- VPC with 6 subnets across 2 AZs (public, web/app, database)
- Public Application Load Balancer (ALB)
- ECS Cluster using AWS Fargate
- ECS Services
  - Next.js Frontend Service
  - Flask Backend Service
- ECS Task Definitions
- Amazon ECR repositories
- RDS MySQL (Multi-AZ optional)
- NAT Gateway (1 or 2 for HA)
- AWS Secrets Manager for credentials
- CloudWatch for logging
- EC2 Docker Host managed through AWS Systems Manager (SSM)

---

# Application Routing

| Path | Destination |
|------|-------------|
| `/` | Next.js Frontend |
| `/api/*` | Flask Backend |

---

# ECS Services

## Next.js Frontend Service

- ECS Fargate launch type
- Container Port: 3000
- Desired Tasks: 2
- Target Group: `ritual-roast-nextjs-tg`

---

## Flask Backend Service

- ECS Fargate launch type
- Container Port: 5000
- Desired Tasks: 2
- Target Group: `ritual-roast-flask-tg`

---

# Security

## Security Groups

### Load Balancer Security Group
- Allow HTTP (80) from `0.0.0.0/0`

### Web/App Security Group
- Allow Port 3000 from Load Balancer SG
- Allow Port 5000 from Load Balancer SG

### Database Security Group
- Allow Port 3306 from Web/App SG only

---

# Secrets Management

- Database credentials stored securely in AWS Secrets Manager
- Automatic secret rotation enabled
- ECS Tasks retrieve secrets securely during runtime

---

# Monitoring

- CloudWatch Logs
- ECS Service Metrics
- ALB Health Checks

---

# Useful Commands

## View ECS Logs

```bash
aws logs tail /aws/ecs/ritual-roast --follow
```

---

## Connect to Docker Host using SSM

```bash
aws ssm start-session --target INSTANCE_ID
```

---

# Cleanup

```bash
terraform destroy -auto-approve
```

---

# Stack

Terraform | AWS ECS Fargate | Docker | Amazon ECR | Application Load Balancer | RDS MySQL | CloudWatch | Secrets Manager | Next.js | Flask

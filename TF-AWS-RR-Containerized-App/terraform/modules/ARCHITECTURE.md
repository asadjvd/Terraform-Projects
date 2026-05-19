# Architecture Overview

# 🏗️ System Architecture Diagram

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                           Internet (0.0.0.0/0)                               │
└───────────────────────────────────┬──────────────────────────────────────────┘
                                    │
                            ┌───────▼────────┐
                            │  Internet      │
                            │   Gateway      │
                            └───────┬────────┘
                                    │
┌───────────────────────────────────┼──────────────────────────────────────────┐
│  VPC: 10.16.0.0/16                │                                          │
│                                   │                                          │
│  ┌────────────────────────────────▼──────────────────────────────────────┐   │
│  │  PUBLIC SUBNETS                                                       │   │
│  │  10.16.0.0/20 (AZ-a) | 10.16.16.0/20 (AZ-b)                           │   │
│  ├───────────────────────────────────────────────────────────────────────┤   │
│  │                                                                       │   │
│  │   ┌──────────────────────────────────────────────────────────────┐    │   │
│  │   │  Application Load Balancer (Internet-facing)                 │    │   │
│  │   │  • HTTP Listener :80                                         │    │   │
│  │   │  • Path-based Routing                                        │    │   │
│  │   │      /        → Next.js Frontend TG :3000                    │    │   │
│  │   │      /api/*   → Flask Backend TG :5000                       │    │   │
│  │   │  • Health Checks                                             │    │   │
│  │   └───────────────────────────┬──────────────────────────────────┘    │   │
│  │                               │                                       │   │
│  │   ┌───────────────────────────▼──────────────────────────────────┐    │   │
│  │   │  NAT Gateway                                                 │    │   │
│  │   │  • Elastic IP                                                │    │   │
│  │   │  • Outbound internet for private subnets                     │    │   │
│  │   └──────────────────────────────────────────────────────────────┘    │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │  WEBAPP PRIVATE SUBNETS (Application Tier)                            │   │
│  │  10.16.64.0/20 (AZ-a) | 10.16.80.0/20 (AZ-b)                          │   │
│  ├───────────────────────────────────────────────────────────────────────┤   │
│  │                                                                       │   │
│  │   ┌──────────────────────────────────────────────────────────────┐    │   │
│  │   │  Amazon ECS Cluster (AWS Fargate)                            │    │   │
│  │   │                                                              │    │   │
│  │   │  Next.js Frontend Service                                    │    │   │
│  │   │   • ECS Fargate Tasks                                        │    │   │
│  │   │   • Container Port: 3000                                     │    │   │
│  │   │   • Desired Tasks: 2                                         │    │   │
│  │   │   • Registered to Frontend Target Group                      │    │   │
│  │   │                                                              │    │   │
│  │   │  Flask Backend Service                                       │    │   │
│  │   │   • ECS Fargate Tasks                                        │    │   │
│  │   │   • Container Port: 5000                                     │    │   │
│  │   │   • Desired Tasks: 2                                         │    │   │
│  │   │   • Retrieves DB secrets from Secrets Manager                │    │   │
│  │   │   • Registered to Backend Target Group                       │    │   │
│  │   │                                                              │    │   │
│  │   │  ECS Task Execution Role                                     │    │   │
│  │   │   • Pull Docker Images from Amazon ECR                       │    │   │
│  │   │   • Push logs to CloudWatch                                  │    │   │
│  │   │   • Access Secrets Manager                                   │    │   │
│  │   └───────────────────────────┬──────────────────────────────────┘    │   │
│  └───────────────────────────────┼───────────────────────────────────────┘   │
│                                  │                                           │
│                                  │                                           │
│  ┌────────────────────────────────▼──────────────────────────────────────┐   │
│  │  DATABASE PRIVATE SUBNETS (Data Tier)                                 │   │
│  │  10.16.192.0/20 (AZ-a) | 10.16.208.0/20 (AZ-b)                        │   │
│  ├───────────────────────────────────────────────────────────────────────┤   │
│  │                                                                       │   │
│  │   ┌──────────────────────────────────────────────────────────────┐    │   │
│  │   │  Amazon RDS MySQL 8.0                                        │    │   │
│  │   │  • Multi-AZ Deployment                                       │    │   │
│  │   │  • Storage: 20GB gp3                                         │    │   │
│  │   │  • Automated Backups                                         │    │   │
│  │   │  • DB Subnet Group                                           │    │   │
│  │   │  • No Public Access                                          │    │   │
│  │   │  • Access allowed only from WebApp SG                        │    │   │
│  │   └──────────────────────────────────────────────────────────────┘    │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │  AMAZON ECR                                                           │   │
│  ├───────────────────────────────────────────────────────────────────────┤   │
│  │                                                                       │   │
│  │   • Next.js Docker Image                                              │   │
│  │   • Flask Docker Image                                                │   │
│  │   • Pulled securely by ECS Tasks                                      │   │
│  │                                                                       │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

# 🔐 Security Groups & Network Flow

```text
┌────────────┐     ┌────────────────────┐     ┌────────────────────┐
│ Internet   │────▶│   ALB SG           │────▶│   WebApp SG       │
│ 0.0.0.0/0  │     │   Allow: 80        │     │   Allow: 3000      │
└────────────┘     └────────────────────┘     │   Allow: 5000      │
                                              │   Source: ALB SG   │
                                              └─────────┬──────────┘
                                                        │
                                                        │
                                                        ▼
                                               ┌────────────────────┐
                                               │   Database SG      │
                                               │   Allow: 3306      │
                                               │ Source: Web SG     │
                                               └────────────────────┘
```

---

# 📊 Data Flow

## Request Flow (User → Database)

### 1. User Request
```text
Internet → Application Load Balancer (Port 80)
```

### 2. ALB Routing
```text
/        → Next.js Frontend ECS Service (Port 3000)

/api/*   → Flask Backend ECS Service (Port 5000)
```

### 3. Backend to Database
```text
Flask Backend → Amazon RDS MySQL (Port 3306)

• Credentials retrieved from AWS Secrets Manager
• Secure private subnet communication
• Database not publicly accessible
```

---

## Response Flow (Database → User)

### 1. Database Query Result
```text
Amazon RDS MySQL → Flask Backend ECS Tasks
```

### 2. Backend Response
```text
Flask Backend → Application Load Balancer
```

### 3. Frontend Delivery
```text
Next.js Frontend → User Browser
```

---

# 🔄 ECS Service Behavior

## ECS Fargate Services

```text
┌────────────────────────────────────────────────────┐
│  Next.js Frontend Service                          │
├────────────────────────────────────────────────────┤
│  Desired Tasks: 2                                  │
│  Launch Type: AWS Fargate                          │
│  Container Port: 3000                              │
│  Registered to ALB Target Group                    │
│  Health Check: /                                   │
│                                                    │
│  Tasks distributed across multiple AZs             │
│  Automatic task replacement on failure             │
└────────────────────────────────────────────────────┘


┌────────────────────────────────────────────────────┐
│  Flask Backend Service                             │
├────────────────────────────────────────────────────┤
│  Desired Tasks: 2                                  │
│  Launch Type: AWS Fargate                          │
│  Container Port: 5000                              │
│  Registered to ALB Target Group                    │
│  Health Check: /api/health                         │
│                                                    │
│  Retrieves secrets from Secrets Manager            │
│  Pulls Docker images from Amazon ECR               │
│  Sends logs to CloudWatch                          │
│  Tasks distributed across multiple AZs             │
└────────────────────────────────────────────────────┘
```

---

# 🔒 IAM Roles & Permissions

```text
┌────────────────────────────────────────────────────┐
│  ECS Task Execution IAM Role                       │
├────────────────────────────────────────────────────┤
│                                                    │
│  • AmazonECSTaskExecutionRolePolicy                │
│    └─▶ Pull Docker images from Amazon ECR          │
│    └─▶ Push container logs to CloudWatch           │
│                                                    │
│  • SecretsManagerReadWrite                         │
│    └─▶ Retrieve database credentials securely      │
│                                                    │
└────────────────────────────────────────────────────┘


┌────────────────────────────────────────────────────┐
│  EC2 Docker Host IAM Role                          │
├────────────────────────────────────────────────────┤
│                                                    │
│  • AmazonSSMManagedInstanceCore                    │
│    └─▶ SSM Session Manager access                  │
│                                                    │
│  • No SSH access exposed publicly                  │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

# 💾 Database Architecture

```text
┌─────────────────────────────────────────────────────┐
│  Amazon RDS MySQL 8.0                               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Engine: MySQL 8.0                                  │
│  Storage: 20GB gp3                                  │
│  Multi-AZ: Enabled                                  │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │  Database: ritualroastdb                    │    │
│  │                                             │    │
│  │  Stores application data for:               │    │
│  │   • User activity                           │    │
│  │   • Orders                                  │    │
│  │   • Application records                     │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  Security:                                          │
│   • Private Database Subnets                        │
│   • No Public Internet Access                       │
│   • Access allowed only from Web/App SG             │
│   • Credentials stored in Secrets Manager           │
│                                                     │
│  Backups:                                           │
│   • Automated Backups Enabled                       │
│   • Retention Period: 7 Days                        │
│                                                     │
│  Monitoring:                                        │
│   • CloudWatch Logs                                 │
│   • Enhanced Monitoring (Optional)                  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

# 📦 Container Architecture

```text
┌─────────────────────────────────────────────────────┐
│  Amazon ECR                                         │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Frontend Repository                                │
│   └─▶ ritual-roast-nextjs-app:latest                │
│                                                     │
│  Backend Repository                                 │
│   └─▶ ritual-roast-flask-app:latest                 │
│                                                     │
│  ECS Tasks pull images securely using IAM Roles     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

# 🔐 Secrets Management

## AWS Secrets Manager: `ritual-roast-db-secret`

```json
{
  "username": "dbadmin",
  "password": "<auto-generated-password>",
  "engine": "mysql",
  "host": "ritual-roast-mysql.xxx.rds.amazonaws.com",
  "port": 3306,
  "dbname": "recipedb"
}
```

---

# 🌐 DNS & Service Discovery

Currently using:

- ALB DNS endpoint for public access
- Internal VPC networking between ECS services and RDS

Future improvements:

- AWS Cloud Map
- Route53 Private Hosted Zones
- Service Mesh / App Mesh

---

# ✅ AWS Well-Architected Principles

✅ Operational Excellence  
- Infrastructure as Code using Terraform  
- Automated ECS deployments  

✅ Security  
- Private subnets  
- Least privilege IAM roles  
- Secrets Manager integration  

✅ Reliability  
- Multi-AZ deployment  
- ECS task self-healing  
- ALB health checks  

✅ Performance Efficiency  
- AWS Fargate serverless containers  
- Load-balanced architecture  

✅ Cost Optimization  
- Single NAT Gateway (optional for dev)  
- Serverless ECS compute model  
- Right-sized database deployment  

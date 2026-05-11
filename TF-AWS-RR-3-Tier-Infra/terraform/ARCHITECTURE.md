# Architecture Overview

## 🏗️ System Architecture Diagram

```
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
│  │   │  Application Load Balancer (Internet-facing)                │     │   │
│  │   │  • HTTP Listener :80                                        │     │   │
│  │   │  • Health Checks                                            │     │   │
│  │   │  • Target Group → EC2 Instances :5000                       │     │   │
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
│  │  WEB PRIVATE SUBNETS (Application Tier)                               │   │
│  │  10.16.64.0/20 (AZ-a) | 10.16.80.0/20 (AZ-b)                          │   │
│  ├───────────────────────────────────────────────────────────────────────┤   │
│  │                                                                       │   │
│  │   ┌──────────────────────────────────────────────────────────────┐    │   │
│  │   │  Auto Scaling Group                                          │    │   │
│  │   │  • EC2 Instances: 2-4 (t3.micro)                             │    │   │
│  │   │  • Launch Template                                           │    │   │
│  │   │      - AMI                                                   │    │   │
│  │   │      - IAM Instance Profile                                  │    │   │
│  │   │      - User Data Script                                      │    │   │
│  │   │  • Flask Application running on Port 5000                    │    │   │
│  │   │  • Pulls source code from S3 Bucket                          │    │   │
│  │   │  • Retrieves DB credentials from Secrets Manager             │    │   │
│  │   │  • Registered to ALB Target Group                            │    │   │
│  │   │  • Health Check: ELB                                         │    │   │
│  │   │  • Scaling Policy: Target Tracking (CPU 70%)                 │    │   │
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
│  │   │  • Instance: db.t3.micro                                     │    │   │
│  │   │  • Storage: 20GB gp3                                         │    │   │
│  │   │  • Automated Backups                                         │    │   │
│  │   │  • DB Subnet Group                                           │    │   │
│  │   │  • No Public Access                                          │    │   │
│  │   │  • Access allowed only from Web/App Security Group           │    │   │
│  │   └──────────────────────────────────────────────────────────────┘    │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## 🔐 Security Groups & Network Flow

```
┌────────────┐     ┌────────────────────┐     ┌────────────────────┐
│ Internet   │────▶│   ALB SG          │────▶│   Web SG           │
│ 0.0.0.0/0  │     │   Allow: 80        │     │   Allow: 5000      │
└────────────┘     └────────────────────┘     │   Source: ALB SG   │
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

## 📊 Data Flow

### Request Flow (User → Database)
```
1. User Request
   └─▶ Internet → ALB (port 80)
       
2. ALB to Web
   └─▶ ALB → Web ASG (port 3000)
       • Load balances across healthy instances
       • Health check: GET / every 30s
       
3. Web to Database
   └─▶ Web → RDS MySQL (port 3306)
       • Credentials from Secrets Manager
       • Connection pooling
       • SSL/TLS encrypted
```

### Response Flow (Database → User)
```
1. Database Query Result
   └─▶ Amazon RDS MySQL → Flask Application (EC2 Instances)

2. Application Response
   └─▶ Flask Application → Application Load Balancer (ALB)

3. ALB Response
   └─▶ ALB → User Browser (HTML/CSS/JSON)

4. User Access
   └─▶ User accesses application via ALB DNS endpoint
```

## 🔄 Auto Scaling Behavior

### Web Application Auto Scaling Group
```
┌────────────────────────────────────────────────────┐
│  Min: 2  │  Desired: 2  │  Max: 4                  │
├────────────────────────────────────────────────────┤
│  Scaling Policy: Target Tracking                   │
│                                                    │
│  Scale Out Trigger: CPU > 70%                      │
│  Action: Launch additional EC2 instance            │
│                                                    │
│  Scale In Trigger: CPU decreases                   │
│  Action: Terminate unnecessary EC2 instance        │
│                                                    │
│  Instances automatically register with ALB         │
│  Health Check Type: ELB                            │
│                                                    │
│  Launch Template Includes:                         │
│   • AMI                                            │
│   • IAM Instance Profile                           │
│   • User Data Bootstrap Script                     │
│                                                    │
│  User Data Actions:                                │
│   • Install Python & Dependencies                  │
│   • Pull Flask Application from S3                 │
│   • Retrieve Secrets from AWS Secrets Manager      │
│   • Start Flask App on Port 5000                   │
└────────────────────────────────────────────────────┘
```

## 🔒 IAM Roles & Permissions

```
┌────────────────────────────────────────────────────┐
│  EC2 Instance IAM Role                             │
├────────────────────────────────────────────────────┤
│  • AmazonSSMManagedInstanceCore                    │
│    └─▶ Session Manager access to EC2 instances     │
│                                                    │
│  • CloudWatchAgentServerPolicy                     │
│    └─▶ Send logs and metrics to CloudWatch         │
│                                                     │
│  • Custom Secrets Manager Policy                    │
│    └─▶ Read database credentials from              │
│        AWS Secrets Manager                          │
│                                                     │
│  • Custom S3 Access Policy                          │
│    └─▶ Download Flask application code             │
│        from S3 bucket during bootstrapping          │
│                                                     │
│  • IAM Instance Profile attached to                 │
│    Auto Scaling Group EC2 instances                 │
└─────────────────────────────────────────────────────┘
```

## 💾 Database Architecture

```
┌─────────────────────────────────────────────────────┐
│  Amazon RDS MySQL 8.0                               │
├─────────────────────────────────────────────────────┤
│  Engine: MySQL 8.0                                  │
│  Instance: db.t3.micro                              │
│  Storage: 20GB gp3                                  │
│  Multi-AZ: Optional (Dev: Disabled)                 │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │  Database: ritualroastdb                    │    │
│  │                                             │    │
│  │  Application stores coffee/order data       │    │
│  │  accessed by Flask application running      │    │
│  │  on EC2 instances                           │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  Security:                                          │
│  • Private Database Subnets                         │
│  • No Public Internet Access                        │
│  • Access allowed only from Web SG                  │
│  • Credentials stored in AWS Secrets Manager        │
│                                                     │
│  Backups:                                           │
│  • Automated Backups Enabled                        │
│  • Retention Period: 7 Days                         │
│  • Manual Snapshots Supported                       │
│                                                     │
│  Monitoring:                                        │
│  • CloudWatch Logs: error, slowquery                │
│  • Performance Insights: Optional                   │
│  • Enhanced Monitoring: Optional                    │
└─────────────────────────────────────────────────────┘
```

## 🌐 DNS & Service Discovery

Currently using internal communication via private IPs within the same VPC.

For production, consider:
- **AWS Cloud Map**: Service discovery
- **Route53 Private Hosted Zone**: Internal DNS
- **Application Mesh**: Advanced service mesh

## 🔐 Secrets Management

```
AWS Secrets Manager: ritualroast-db-secret
┌─────────────────────────────────────────────────────┐
│  {                                                  │
│    "username": "dbadmin",                           │
│    "password": "<auto-generated-32-char>",          │
│    "engine": "mysql",                               │
│    "host": "dev-ritual-roast-mysql.xxx.rds...",     │
│    "port": 3306,                                    │
│    "dbname": "ritualroastdb"                        │
│  }                                                  │
└─────────────────────────────────────────────────────┘
```

---

This architecture implements AWS Well-Architected Framework principles:
- ✅ **Operational Excellence**: Infrastructure as Code, automated deployments
- ✅ **Security**: Defense in depth, encryption, least privilege
- ✅ **Reliability**: Multi-AZ, auto-scaling, health checks
- ✅ **Performance Efficiency**: Right-sized instances, auto-scaling
- ✅ **Cost Optimization**: Single NAT (dev), auto-scaling, gp3 storage

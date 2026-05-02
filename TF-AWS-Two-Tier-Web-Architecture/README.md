# AWS Terraform 2-Tier Web Architecture (with Load Balancer)

---

### **1. Project Overview**

This project provisions a highly available web architecture on AWS using Terraform. It includes a custom VPC, public subnets across two availability zones, EC2 instances running a simple web server, an Application Load Balancer, and an S3 bucket.

The architecture demonstrates core DevOps and Cloud skills including:
* Infrastructure as Code (Terraform)
* AWS networking (VPC, subnets, routing)
* EC2 provisioning
* Security groups configuration
* Load balancing (ALB)

---

### **2. Architecture Diagram**

---

<img src="Images/TF-AWS_Proj.png">

---

### **3. Infrastructure Components**

---

**1. Custom VPC**
* CIDR block defined for isolated networking
* Enables full control over AWS networking

<img src="Images/vpc-resource-map.PNG">

---

```bash
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}
```

---

**2. Public Subnets**

* Two public subnets deployed in:
  * us-east-1a
  * us-east-1b
* Used for high availability across AZs

```bash
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}
```

---



```

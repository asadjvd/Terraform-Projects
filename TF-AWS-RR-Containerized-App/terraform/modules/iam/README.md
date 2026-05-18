# IAM Module

This module creates IAM roles for ECS and EC2 instance. Also, an instance profiles for EC2 instance in the Ritual Roast application.

## Features

- ECS and EC2 instance role with assume role policy
- Systems Manager (SSM) access for Session Manager
- Secrets Manager access for database credentials
- ECR access to pull images from Amazon ECR 
- Instance profile for EC2 attachment

## Usage

```hcl
module "iam" {
  source = "../../modules/iam"

  environment  = "dev"
  project      = "ritual-roast"
  secrets_arns = [module.secrets.db_secret_arn]

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
| secrets_arns | Secrets Manager ARNs | list(string) | ["*"] | no |
| tags | Common tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| ec2_role_arn | EC2 IAM role ARN |
| ec2_role_name | EC2 IAM role name |
| ec2_instance_profile_arn | Instance profile ARN |
| ec2_instance_profile_name | Instance profile name |
| ecs_task_execution_role_arn | ECS Task Execution role ARN |
| ecs_task_execution_role_name | ECS Task Execution role name |

## Permissions

The EC2 role includes:
- **AmazonSSMManagedInstanceCore**: Session Manager access (no SSH keys needed)
- **AmazonEC2ContainerRegistryPowerUser**: To create repositories and push images to Amazon ECR

The ECS role include: 
- **Custom Secrets Manager Policy**: Read database credentials


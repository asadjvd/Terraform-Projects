# ECS Task Execution ROle
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-${var.project}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-ecs-task-execution-role"
    }
  )
}

# ECS TASK EXECUTION POLICY
# Pull ECR Images + CloudWatch Logs
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role = aws_iam_role.ecs_task_execution_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Secrets Manager Access
resource "aws_iam_policy" "ecs_secrets_policy" {
  name = "${var.environment}-${var.project}-ecs-secrets-policy"

  description = "Allow ECS tasks to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secrets_arns
      }
    ]
  })
  tags = var.tags
}


resource "aws_iam_role_policy_attachment" "ecs_secrets_attach" {
  role = aws_iam_role.ecs_task_execution_role.name

  policy_arn = aws_iam_policy.ecs_secrets_policy.arn
}

# EC2 ROLE
resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-${var.project}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"

        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-ec2-role"
    }
  )
}

# EC2 SSM ACCESS
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 CLOUDWATCH ACCESS
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# EC2 ECR ACCESS
# Push/Pull Docker Images
resource "aws_iam_role_policy_attachment" "ecr_access" {
  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# EC2 SECRETS MANAGER ACCESS
resource "aws_iam_policy" "ec2_secrets_policy" {
  name = "${var.environment}-${var.project}-ec2-secrets-policy"

  description = "Allow EC2 instances to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = var.secrets_arns
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ec2_secrets_attach" {
  role = aws_iam_role.ec2_role.name

  policy_arn = aws_iam_policy.ec2_secrets_policy.arn
}

# EC2 INSTANCE PROFILE
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-${var.project}-ec2-instance-profile"

  role = aws_iam_role.ec2_role.name

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-ec2-instance-profile"
    }
  )
}
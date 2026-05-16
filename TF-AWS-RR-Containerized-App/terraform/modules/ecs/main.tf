# ECS Cluster
resource "aws_ecs_cluster" "rr_cluster" {
  name = "${var.environment}-${var.project}-cluster"

  tags = merge(
    {
      Name = "${var.environment}-${var.project}-cluster"
    }
  )
}

# ECS Frontend Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "ritual-roast-nextjs-frontend-task-def"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "ritual-roast-nextjs-container"
      image     = var.frontend_image
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = var.tags
}

# ECS Backend Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "ritual-roast-flask-backend-task-def"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "ritual-roast-flask-container"
      image     = var.backend_image
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
      secrets = [
        {
          name      = "DB_SECRET"
          valueFrom = var.secret_arn
        }
      ]
    }
  ])

  tags = var.tags
}

# ECS Frontend Service
resource "aws_ecs_service" "frontend" {
  name                               = "ritual-roast-nextjs-frontend-service"
  cluster                            = aws_ecs_cluster.rr_cluster.id
  task_definition                    = aws_ecs_task_definition.frontend.arn
  desired_count                      = 2
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.webapp_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "ritual-roast-nextjs-container"
    container_port   = 3000
  }

  depends_on = [
    var.frontend_listener_arn
  ]

  tags = var.tags
}

# ECS Backend Service
resource "aws_ecs_service" "backend" {
  name                               = "ritual-roast-flask-backend-service"
  cluster                            = aws_ecs_cluster.rr_cluster.id
  task_definition                    = aws_ecs_task_definition.backend.arn
  desired_count                      = 2
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.webapp_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = "ritual-roast-flask-container"
    container_port   = 5000
  }

  depends_on = [
    var.backend_listener_arn
  ]

  tags = var.tags
}


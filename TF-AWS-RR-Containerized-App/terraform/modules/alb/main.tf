# ALB
resource "aws_lb" "main" {
  name = "${var.environment}-${var.project}-alb"

  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.security_group_id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-alb"
    }
  )
}

# Frontend TG
resource "aws_lb_target_group" "frontend" {
  name = "${var.environment}-${var.project}-frontend-tg"

  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-frontend-tg"
    }
  )
}

# Backend TG
resource "aws_lb_target_group" "backend" {
  name = "${var.environment}-${var.project}-backend-tg"

  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/api/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-backend-tg"
    }
  )
}

# Frontend Listener Rule
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  tags = var.tags
}

# Backend Listener Rule
resource "aws_lb_listener_rule" "backend_api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  tags = var.tags
}
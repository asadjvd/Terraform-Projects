resource "aws_lb" "main" {
  name               = "${var.environment}-${var.project}-alb"

  load_balancer_type = "application"

  security_groups = [var.security_group_id]

  subnets = values(var.subnet_ids)

  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-alb"
    }
  )
}

resource "aws_lb_target_group" "main" {
  name = "${var.environment}-${var.project}-tg"
  port     = var.target_group_port
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "instance"

  health_check {
    enabled = true
    protocol = "HTTP"
    path = "/"
    port = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout  = 5
    interval = 30
    matcher = "200"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-tg"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port     = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = var.tags
}
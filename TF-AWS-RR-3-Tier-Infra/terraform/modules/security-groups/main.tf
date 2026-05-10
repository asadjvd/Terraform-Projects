resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-${var.project}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic from Internet to Application Load Balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-alb-sg"
    }
  )
}

resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-${var.project}-web-sg"
  description = "Security group for Web Application"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allows HTTP traffic from Application Load Balancers to Web App Servers"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-web-sg"
    }
  )
}

resource "aws_security_group" "database_sg" {
  name        = "${var.environment}-${var.project}-database-sg"
  description = "Security group for RDS MySQL database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allows MySQL traffic from Web App Servers to Database"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    description = "No outbound traffic allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-database-sg"
    }
  )
}

resource "aws_security_group_rule" "database_self" {
  type = "ingress"

  description = "Allow MySQL traffic within same SG"

  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"

  security_group_id        = aws_security_group.database_sg.id
  source_security_group_id = aws_security_group.database_sg.id
}
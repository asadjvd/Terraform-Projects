# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "docker_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id
  iam_instance_profile   = var.iam_instance_profile

  user_data = templatefile("${path.root}/../../userdata.sh", {
    frontend           = var.frontend
    backend            = var.backend
    backend_url        = var.backend_url
    frontend_url       = var.frontend_url
    frontend_repo_name = var.frontend_repo_name
    backend_repo_name  = var.backend_repo_name
    region             = var.region
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-docker-server"
    }
  )
}


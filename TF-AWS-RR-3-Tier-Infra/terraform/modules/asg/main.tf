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

resource "aws_launch_template" "webapp" {
  name_prefix = "${var.environment}-${var.project}-webapp-"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = base64encode(templatefile("${path.root}/../../user-data.sh", {
    bucket_name = var.bucket_name
  }))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-${var.project}-webapp"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-${var.project}-webapp-volume"
      }
    )
  }
}

resource "aws_autoscaling_group" "webapp" {
  name = "${var.environment}-${var.project}-webapp-asg"

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  vpc_zone_identifier = values(var.subnet_ids)
  target_group_arns = [var.target_group_arn]
  health_check_type = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.webapp.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-${var.project}-webapp"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "cpu_tracking" {
  name = "${var.environment}-${var.project}-cpu-tracking"

  autoscaling_group_name = aws_autoscaling_group.webapp.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70
  }
}
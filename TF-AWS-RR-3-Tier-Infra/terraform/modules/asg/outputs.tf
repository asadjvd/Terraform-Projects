output "asg_name" {
  value = aws_autoscaling_group.webapp.name
}

output "asg_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.webapp.id
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.webapp.arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.webapp.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.webapp.latest_version
}
output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.main.name
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

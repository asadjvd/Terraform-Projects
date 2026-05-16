output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend.arn
}

output "backend_target_group_arn" {
  value = aws_lb_target_group.backend.arn
}

output "frontend_listener_arn" {
  value = aws_lb_listener.http.arn
}

output "backend_listener_arn" {
  value = aws_lb_listener.http.arn
}
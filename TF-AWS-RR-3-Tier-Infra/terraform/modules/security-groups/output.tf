output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "web_sg_id" {
  description = "ID of the Web security group"
  value       = aws_security_group.web_sg.id
}

output "database_sg_id" {
  description = "ID of the Database security group"
  value       = aws_security_group.database_sg.id
}
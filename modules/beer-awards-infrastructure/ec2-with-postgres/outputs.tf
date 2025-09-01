# Outputs for EC2 with PostgreSQL Module

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.backend.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.backend.arn
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.backend.private_ip
}

output "public_ip" {
  description = "Public IP address of the EC2 instance (if in public subnet)"
  value       = aws_instance.backend.public_ip
}

output "availability_zone" {
  description = "Availability zone where the instance is running"
  value       = aws_instance.backend.availability_zone
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = aws_instance.backend.instance_state
}

output "backend_endpoint" {
  description = "Backend application endpoint"
  value       = "http://${aws_instance.backend.private_ip}:${var.backend_port}"
}

output "health_check_url" {
  description = "Health check endpoint URL"
  value       = "http://${aws_instance.backend.private_ip}:${var.backend_port}/api/v1/health"
}

output "database_endpoint" {
  description = "Local PostgreSQL connection endpoint"
  value       = "${aws_instance.backend.private_ip}:5432"
}

output "security_group_id" {
  description = "Security group ID attached to the instance"
  value       = var.security_group_id
}

# CloudWatch Log Groups
output "backend_log_group" {
  description = "CloudWatch log group for backend logs"
  value       = aws_cloudwatch_log_group.backend_logs.name
}

output "postgres_log_group" {
  description = "CloudWatch log group for PostgreSQL logs" 
  value       = aws_cloudwatch_log_group.postgres_logs.name
}
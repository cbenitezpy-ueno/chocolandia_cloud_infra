# Outputs for Ultra Simple Beer Awards Infrastructure

# Networking
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc_simple.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc_simple.vpc_cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc_simple.public_subnet_id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc_simple.internet_gateway_id
}

# Security Groups
output "ec2_security_group_id" {
  description = "ID of the EC2 security group" 
  value       = module.security_groups_simple.backend_security_group_id
}

# EC2 Instance
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_with_postgres.instance_id
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.ec2_with_postgres.private_ip
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2_with_postgres.public_ip
}

output "backend_health_check_url" {
  description = "Backend health check URL"
  value       = module.ec2_with_postgres.health_check_url
}

# S3 Frontend
output "frontend_bucket_id" {
  description = "ID of the frontend S3 bucket"
  value       = module.frontend_s3.bucket_id
}

output "frontend_website_url" {
  description = "S3 static website URL"
  value       = module.frontend_s3.website_url
}

output "frontend_website_endpoint" {
  description = "S3 website endpoint"
  value       = module.frontend_s3.website_endpoint
}

# Application URLs
output "application_url" {
  description = "Main application URL (direct to EC2)"
  value       = "http://${module.ec2_with_postgres.public_ip}:${var.backend_port}"
}

output "api_url" {
  description = "Backend API URL"
  value       = "http://${module.ec2_with_postgres.public_ip}:${var.backend_port}/api/v1"
}

output "health_check_url" {
  description = "Application health check URL"
  value       = "http://${module.ec2_with_postgres.public_ip}:${var.backend_port}/api/v1/health"
}

# Database
output "database_endpoint" {
  description = "PostgreSQL database endpoint (local)"
  value       = "${module.ec2_with_postgres.private_ip}:5432"
}

# CloudWatch
output "backend_log_group" {
  description = "CloudWatch log group for backend"
  value       = module.ec2_with_postgres.backend_log_group
}

output "postgres_log_group" {
  description = "CloudWatch log group for PostgreSQL"
  value       = module.ec2_with_postgres.postgres_log_group
}

# Cost and Architecture Info
output "estimated_monthly_cost" {
  description = "Estimated monthly cost in USD"
  value       = "$8-12 (with free tier: $5-8)"
}

output "architecture_summary" {
  description = "Architecture summary"
  value       = "Single EC2 (${var.backend_instance_type}) + Local PostgreSQL + S3 Website + Direct Access (No ALB)"
}

output "cost_optimizations" {
  description = "Applied cost optimizations"
  value = [
    "Single AZ deployment (EC2 in public subnet)",
    "Local PostgreSQL instead of RDS ($20-30/month savings)",
    "S3 static website instead of CloudFront ($10-20/month savings)",
    "No ALB - direct EC2 access ($16/month savings)", 
    "No NAT Gateway needed ($15-45/month savings)",
    "Basic monitoring only",
    "No redundancy (dev environment)"
  ]
}
# EC2 Instance with Local PostgreSQL for Beer Awards
# Ultra cost-optimized setup for development

# Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data script for EC2 initialization
locals {
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    backend_port          = var.backend_port
    jwt_secret           = var.jwt_secret
    frontend_url         = var.frontend_url
    db_name             = var.db_name
    db_username         = var.db_username
    db_password         = var.db_password
    new_relic_license_key = var.new_relic_license_key
    new_relic_app_name   = var.new_relic_app_name
    name_prefix         = var.name_prefix
  }))
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name_prefix = "${var.name_prefix}-ec2-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for EC2 (CloudWatch, SSM, etc.)
resource "aws_iam_role_policy" "ec2_policy" {
  name_prefix = "${var.name_prefix}-ec2-policy-"
  role        = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "${var.name_prefix}-ec2-profile-"
  role        = aws_iam_role.ec2_role.name

  tags = var.tags
}

# EC2 Instance
resource "aws_instance" "backend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name              = var.key_name
  subnet_id             = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = local.user_data

  # Storage
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true

    tags = merge(var.tags, {
      Name = "${var.name_prefix}-root-volume"
    })
  }

  # Instance metadata options for security
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"  # Require IMDSv2
    http_put_response_hop_limit = 1
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-backend-ec2"
    Type = "Backend"
    Database = "Local PostgreSQL"
  })

  # Lifecycle
  lifecycle {
    create_before_destroy = true
  }
}

# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "backend_logs" {
  name              = "/aws/ec2/${var.name_prefix}/backend"
  retention_in_days = 3  # Short retention for dev

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-backend-logs"
  })
}

# CloudWatch Log Group for PostgreSQL logs
resource "aws_cloudwatch_log_group" "postgres_logs" {
  name              = "/aws/ec2/${var.name_prefix}/postgresql"
  retention_in_days = 3

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-postgres-logs"
  })
}
# Variables for Beer Awards Development Environment

# AWS Configuration
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "owner_email" {
  description = "Email of the project owner for tagging"
  type        = string
  default     = "dev@chocolandia.com"
}

# Networking Configuration - Ultra Simple
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet (EC2 placement)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access EC2 directly"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Open for development
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed SSH access to EC2"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Restrict this in production
}

# EC2 Configuration
variable "backend_instance_type" {
  description = "EC2 instance type (free tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_pair_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  # This must be provided when deploying
}

variable "backend_port" {
  description = "Port the backend listens on"
  type        = number
  default     = 3001
}

# Local PostgreSQL Configuration
variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "beer_awards_dev"
}

variable "db_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "postgres"
}

# Optional New Relic Configuration
variable "new_relic_license_key" {
  description = "New Relic license key (optional for dev)"
  type        = string
  sensitive   = true
  default     = ""
}

# Cost Control Features
variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown during off hours"
  type        = bool
  default     = true
}

variable "shutdown_schedule" {
  description = "Cron expression for shutdown (stop at 8 PM)"
  type        = string
  default     = "0 20 * * *"
}

variable "startup_schedule" {
  description = "Cron expression for startup (start at 8 AM)"
  type        = string
  default     = "0 8 * * *"
}

variable "weekend_shutdown" {
  description = "Shutdown on weekends to save costs"
  type        = bool
  default     = true
}
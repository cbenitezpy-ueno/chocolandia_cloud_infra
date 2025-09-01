# Variables for Beer Awards Infrastructure Module - DEV SIMPLIFIED

# General Configuration
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "beer-awards"
}

variable "environment" {
  description = "Environment name (dev)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Feature Toggles for Cost Optimization
variable "enable_database" {
  description = "Enable RDS database (set to false to use local SQLite for ultra-low cost)"
  type        = bool
  default     = false  # Start without RDS, enable only when needed
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring and logging"
  type        = bool
  default     = false  # Basic monitoring only
}

# Networking Configuration - SIMPLIFIED
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (only 2 for cost optimization)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (only 2 for cost optimization)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets (only 2 for cost optimization)"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

# Single subnet override for ultra-simple setup
variable "public_subnet_cidr" {
  description = "Single public subnet CIDR (ultra-simple setup)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Open for dev, restrict for prod
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Open for dev, restrict for prod
}

# Database Configuration - BASIC
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "beer_awards_dev"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

# EC2 Backend Configuration - COST OPTIMIZED
variable "backend_instance_type" {
  description = "EC2 instance type for backend (t3.micro for free tier)"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_pair_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

variable "backend_port" {
  description = "Port the backend application listens on"
  type        = number
  default     = 3001
}

# Application Configuration
variable "frontend_url" {
  description = "Frontend URL for CORS configuration"
  type        = string
  default     = "http://localhost:3000"
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
}

variable "frontend_domain_name" {
  description = "Custom domain name for frontend (optional)"
  type        = string
  default     = ""
}

# New Relic Configuration (Optional)
variable "new_relic_license_key" {
  description = "New Relic license key for monitoring (optional for dev)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "new_relic_app_name" {
  description = "New Relic application name"
  type        = string
  default     = "beer-awards-dev"
}

# Development Specific Variables
variable "auto_shutdown_enabled" {
  description = "Enable automatic shutdown of resources during off-hours to save costs"
  type        = bool
  default     = true
}

variable "auto_shutdown_schedule" {
  description = "Cron expression for auto-shutdown (default: stop at 6 PM weekdays)"
  type        = string
  default     = "0 18 ? * MON-FRI *"
}

variable "auto_startup_schedule" {
  description = "Cron expression for auto-startup (default: start at 8 AM weekdays)"  
  type        = string
  default     = "0 8 ? * MON-FRI *"
}

# Cost Control
variable "max_monthly_budget" {
  description = "Maximum monthly budget in USD (alerts when exceeded)"
  type        = number
  default     = 50
}

variable "budget_alert_email" {
  description = "Email address for budget alerts"
  type        = string
  default     = ""
}
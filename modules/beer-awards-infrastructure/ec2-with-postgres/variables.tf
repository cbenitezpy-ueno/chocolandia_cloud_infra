# Variables for EC2 with PostgreSQL Module

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking
variable "subnet_id" {
  description = "ID of the subnet where EC2 instance will be launched"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group for the EC2 instance"
  type        = string
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

# Application Configuration
variable "backend_port" {
  description = "Port the backend application listens on"
  type        = number
  default     = 3001
}

variable "jwt_secret" {
  description = "JWT secret key for the application"
  type        = string
  sensitive   = true
}

variable "frontend_url" {
  description = "Frontend URL for CORS configuration"
  type        = string
  default     = ""
}

# Local PostgreSQL Configuration
variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "beer_awards"
}

variable "db_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

# Optional New Relic Configuration
variable "new_relic_license_key" {
  description = "New Relic license key (optional)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "new_relic_app_name" {
  description = "New Relic application name"
  type        = string
  default     = ""
}
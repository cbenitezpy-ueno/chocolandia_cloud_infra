variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "backend_port" {
  description = "Port for backend application"
  type        = number
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access backend"
  type        = list(string)
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed SSH access"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
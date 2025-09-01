# Variables for S3 Static Website Module

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "backend_url" {
  description = "Backend API URL for CORS and health checks"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
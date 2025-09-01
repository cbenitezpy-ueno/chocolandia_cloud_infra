# Beer Awards Infrastructure - Ultra Simplified Version
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

locals {
  common_tags = merge(var.tags, {
    Application = "beer-awards"
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "beer-awards-infrastructure"
    CostProfile = "development-optimized"
  })
  
  name_prefix = "${var.project_name}-${var.environment}"
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module
module "vpc_simple" {
  source = "./vpc-simple"
  
  name_prefix             = local.name_prefix
  vpc_cidr               = var.vpc_cidr
  public_subnet_cidrs    = [var.public_subnet_cidr]
  private_subnet_cidrs   = ["10.0.2.0/24"]  # Not used but required
  database_subnet_cidrs  = ["10.0.3.0/24"]  # Not used but required
  availability_zones     = [data.aws_availability_zones.available.names[0]]
  
  single_nat_gateway     = true
  enable_vpc_endpoints   = false
  
  tags = local.common_tags
}

# Security Groups
module "security_groups_simple" {
  source = "./security-groups-simple"
  
  name_prefix         = local.name_prefix
  vpc_id             = module.vpc_simple.vpc_id
  backend_port       = var.backend_port
  allowed_cidr_blocks = var.allowed_cidr_blocks
  ssh_cidr_blocks    = var.ssh_cidr_blocks
  
  tags = local.common_tags
}

# IAM
module "iam_simple" {
  source = "./iam-simple"
  
  name_prefix = local.name_prefix
  tags        = local.common_tags
}

# EC2 with PostgreSQL
module "ec2_with_postgres" {
  source = "./ec2-with-postgres"
  
  name_prefix       = local.name_prefix
  instance_type     = var.backend_instance_type
  key_name          = var.ec2_key_pair_name
  subnet_id         = module.vpc_simple.public_subnet_id
  security_group_id = module.security_groups_simple.backend_security_group_id
  
  # Application configuration
  backend_port = var.backend_port
  jwt_secret   = var.jwt_secret
  frontend_url = var.frontend_url
  
  # Database configuration
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  
  # Optional monitoring
  new_relic_license_key = var.new_relic_license_key
  new_relic_app_name   = var.new_relic_app_name
  
  tags = local.common_tags
}

# Frontend S3
module "frontend_s3" {
  source = "./frontend-s3-simple"
  
  name_prefix  = local.name_prefix
  bucket_name  = "${local.name_prefix}-frontend-${random_id.bucket_suffix.hex}"
  backend_url  = "http://EC2_PUBLIC_IP:${var.backend_port}"  # Will be updated after deployment
  tags         = local.common_tags
}

# Random suffix for unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
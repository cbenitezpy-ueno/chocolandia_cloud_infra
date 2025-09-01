# Beer Awards Development Environment
# Account ID: 353385936485
# Ultra cost-optimized setup with local PostgreSQL

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

# Configure AWS Provider for Development Account
provider "aws" {
  region = var.aws_region
  
  # Development account ID (within Chocolandia organization)
  allowed_account_ids = ["353385936485"]
  
  default_tags {
    tags = {
      Environment   = "development"
      Project       = "beer-awards"
      Owner         = "chocolandia"
      ManagedBy     = "terraform"
      CostCenter    = "development"
      Application   = "beer-awards-platform"
    }
  }
}

# Local variables
locals {
  environment = "dev"
  project_name = "beer-awards"
  
  common_tags = {
    Environment = local.environment
    Project     = local.project_name
    Owner       = var.owner_email
    CreatedBy   = "terraform"
    Region      = var.aws_region
  }
}

# Random password generation for database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "random_password" "jwt_secret" {
  length  = 32
  special = false
}

# Deploy the ultra-simple Beer Awards infrastructure
module "beer_awards_infrastructure" {
  source = "../../modules/beer-awards-infrastructure"
  
  # Basic configuration
  project_name = local.project_name
  environment  = local.environment
  
  # Networking
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  
  # Access control
  allowed_cidr_blocks = var.allowed_cidr_blocks
  ssh_cidr_blocks     = var.ssh_cidr_blocks
  
  # EC2 Configuration
  backend_instance_type = var.backend_instance_type
  ec2_key_pair_name    = var.ec2_key_pair_name
  backend_port         = var.backend_port
  
  # Application secrets
  jwt_secret   = random_password.jwt_secret.result
  
  # Database configuration
  db_name     = var.db_name
  db_username = var.db_username
  db_password = random_password.db_password.result
  
  # Optional monitoring
  new_relic_license_key = var.new_relic_license_key
  new_relic_app_name   = "${local.project_name}-${local.environment}"
  
  tags = local.common_tags
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Random ID for unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
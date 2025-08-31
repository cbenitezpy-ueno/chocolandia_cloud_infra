# Core Infrastructure
module "core" {
  source = "./core"
}

# Production Infrastructure
module "production" {
  source = "./production"
}

# Staging Infrastructure
module "staging" {
  source = "./staging"
}

# Development Infrastructure
module "development" {
  source = "./development"
}
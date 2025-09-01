# Outputs for Beer Awards Development Environment

# Infrastructure Information
output "infrastructure_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    account_id        = data.aws_caller_identity.current.account_id
    region           = data.aws_region.current.name
    environment      = "development"
    architecture     = "Ultra-simple single AZ + local PostgreSQL + direct access"
    estimated_cost   = "$8-12/month (free tier: $5-8/month)"
  }
}

# Application Access URLs
output "application_urls" {
  description = "URLs to access the application"
  value = {
    frontend_website = module.beer_awards_infrastructure.frontend_website_url
    backend_api      = module.beer_awards_infrastructure.api_url
    health_check     = module.beer_awards_infrastructure.health_check_url
    backend_direct   = module.beer_awards_infrastructure.application_url
  }
}

# Infrastructure Details
output "infrastructure_details" {
  description = "Detailed infrastructure information"
  value = {
    vpc_id                = module.beer_awards_infrastructure.vpc_id
    ec2_instance_id       = module.beer_awards_infrastructure.ec2_instance_id
    ec2_public_ip        = module.beer_awards_infrastructure.ec2_public_ip
    frontend_bucket      = module.beer_awards_infrastructure.frontend_bucket_id
    database_endpoint    = module.beer_awards_infrastructure.database_endpoint
  }
}

# Connection Information
output "connection_info" {
  description = "Information needed to connect to services"
  sensitive   = true
  value = {
    database = {
      host     = split(":", module.beer_awards_infrastructure.database_endpoint)[0]
      port     = split(":", module.beer_awards_infrastructure.database_endpoint)[1]
      database = var.db_name
      username = var.db_username
      password = random_password.db_password.result
    }
    application = {
      jwt_secret = random_password.jwt_secret.result
    }
  }
}

# Cost Optimization Features
output "cost_optimizations" {
  description = "Cost optimization features enabled"
  value = {
    auto_shutdown_enabled = var.enable_auto_shutdown
    shutdown_schedule     = var.shutdown_schedule
    startup_schedule      = var.startup_schedule
    weekend_shutdown      = var.weekend_shutdown
    optimizations         = module.beer_awards_infrastructure.cost_optimizations
  }
}

# Monitoring
output "monitoring" {
  description = "Monitoring and logging information"
  sensitive   = true
  value = {
    backend_logs    = module.beer_awards_infrastructure.backend_log_group
    postgres_logs   = module.beer_awards_infrastructure.postgres_log_group
    new_relic_enabled = var.new_relic_license_key != ""
  }
}

# Deployment Instructions
output "deployment_instructions" {
  description = "Instructions for deploying the application"
  value = {
    step_1 = "SSH to EC2 instance: ssh -i your-key.pem ec2-user@${module.beer_awards_infrastructure.ec2_public_ip}"
    step_2 = "Check application status: sudo beer-awards-status"
    step_3 = "View application logs: sudo tail -f /var/log/beer-awards/app.log"
    step_4 = "Access application directly: ${module.beer_awards_infrastructure.application_url}"
    step_5 = "Frontend S3 website: ${module.beer_awards_infrastructure.frontend_website_url}"
  }
}
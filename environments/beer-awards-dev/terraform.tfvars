# AWS Configuration
aws_region = "us-east-1"
owner_email = "dev@chocolandia.com"

# Networking
vpc_cidr = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"

# Access Control (IMPORTANT: Restrict these for security)
allowed_cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere (DEV ONLY!)
ssh_cidr_blocks = ["0.0.0.0/0"]      # Allow SSH from anywhere (DEV ONLY!)

# EC2 Configuration
backend_instance_type = "t3.micro"  # Free tier eligible
ec2_key_pair_name = "beer-awards-dev-key"  # Create this key pair first!
backend_port = 3001

# Database Configuration (Local PostgreSQL)
db_name = "beer_awards_dev"
db_username = "beer_admin"

# Optional: New Relic Monitoring (leave empty to disable)
new_relic_license_key = ""

# Cost Optimization Features
enable_auto_shutdown = true
shutdown_schedule = "cron(0 20 * * ? *)"  # 8 PM daily
startup_schedule = "cron(0 8 * * ? *)"    # 8 AM daily  
weekend_shutdown = true
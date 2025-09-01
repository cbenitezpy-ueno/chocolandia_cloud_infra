# Beer Awards Development Environment

Ultra cost-optimized AWS infrastructure for the Beer Awards Platform development environment.

## Architecture Overview

- **Account**: 353385936485 (Chocolandia Organization)
- **Estimated Cost**: $8-12/month ($5-8 with free tier)
- **Architecture**: Single AZ + EC2 Direct Access + Local PostgreSQL

### Infrastructure Components

1. **VPC**: Single AZ deployment with one public subnet only
2. **EC2**: Single t3.micro instance in public subnet with direct internet access
3. **PostgreSQL**: Local database running on EC2 instance
4. **S3**: Static website hosting for frontend (no CloudFront)
5. **CloudWatch**: Basic logging and monitoring only

### Architecture Diagram
```
Internet
   │
   ▼
┌─────────────────────────────┐
│         VPC 10.0.0.0/16     │
│  ┌───────────────────────┐  │
│  │  Public Subnet        │  │
│  │  10.0.1.0/24         │  │
│  │                       │  │
│  │  ┌─────────────────┐  │  │
│  │  │   EC2 Instance  │  │  │
│  │  │   - Node.js App │  │  │
│  │  │   - PostgreSQL  │  │  │
│  │  │   - Public IP   │  │  │
│  │  │   Port: 3001    │  │  │
│  │  └─────────────────┘  │  │
│  └───────────────────────┘  │
└─────────────────────────────┘

┌─────────────────────────────┐
│     S3 Static Website       │
│     Frontend Hosting        │
│     ↓ API calls to EC2      │
└─────────────────────────────┘
```

### Cost Optimizations

- **Single AZ deployment**: EC2 in public subnet only
- **No Application Load Balancer**: Direct access saves ~$16/month
- **No NAT Gateway**: Public subnet eliminates need, saves $15-45/month
- **Local PostgreSQL instead of RDS**: Saves $20-30/month
- **S3 static website instead of CloudFront**: Saves $10-20/month
- **Auto-shutdown during off-hours**: Saves ~50% compute costs
- **Basic monitoring only**: Minimal CloudWatch usage
- **t3.micro instance**: Free tier eligible (750 hours/month)

### Total Monthly Savings vs Full Setup
- **Original full setup**: $80-120/month
- **This ultra-optimized setup**: $5-8/month (with free tier)
- **Total savings**: $75-115/month (90%+ cost reduction)

## Prerequisites

### 1. AWS Setup
- Access to AWS account 353385936485
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed

### 2. Create EC2 Key Pair
```bash
# Create key pair in AWS Console or via CLI
aws ec2 create-key-pair --key-name beer-awards-dev-key --query 'KeyMaterial' --output text > ~/.ssh/beer-awards-dev-key.pem
chmod 400 ~/.ssh/beer-awards-dev-key.pem
```

### 3. Configure Variables
```bash
# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your specific values
vi terraform.tfvars
```

## Deployment

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Plan Deployment
```bash
terraform plan
```

### 3. Deploy Infrastructure
```bash
terraform apply
```

### 4. Get Connection Information
```bash
# Get application URLs
terraform output application_urls

# Get sensitive connection info (database passwords, etc.)
terraform output -json connection_info
```

## Post-Deployment

### 1. Verify Application Health
```bash
# Check health endpoint (direct access)
curl $(terraform output -raw health_check_url)

# Expected response:
# {"status":"ok","timestamp":"...","service":"beer-awards-backend","database":"postgresql-local"}

# Or check via browser
# http://<EC2_PUBLIC_IP>:3001/api/v1/health
```

### 2. SSH to EC2 Instance
```bash
# Get public IP (direct access)
PUBLIC_IP=$(terraform output -raw ec2_public_ip)

# SSH directly to EC2 (no bastion needed)
ssh -i ~/.ssh/beer-awards-dev-key.pem ec2-user@$PUBLIC_IP

# Check application status
sudo beer-awards-status
```

### 3. View Application Logs
```bash
# Application logs
sudo tail -f /var/log/beer-awards/app.log

# PostgreSQL logs  
sudo tail -f /var/log/postgresql/postgresql*.log

# User data installation log
sudo tail -f /var/log/user-data.log
```

## Application Deployment

The EC2 instance includes a placeholder health check server. To deploy the actual Beer Awards application:

### 1. Clone Repository
```bash
sudo -u beerapp bash
cd /opt/beer-awards

# Remove placeholder server
rm server.js

# Clone actual application (update with your repo URL)
git clone https://github.com/your-org/beer-awards-backend.git .
```

### 2. Install Dependencies  
```bash
# Install backend dependencies
pnpm install

# Build application
pnpm build
```

### 3. Update PM2 Configuration
```bash
# Update ecosystem.config.js with actual application entry point
vi ecosystem.config.js

# Restart application
pm2 restart ecosystem.config.js
```

### 4. Update Frontend
```bash
# Build frontend locally and upload to S3
cd /path/to/frontend

# Update API URL to point to EC2 public IP
# Edit your environment variables to use:
# NEXT_PUBLIC_API_URL=http://<EC2_PUBLIC_IP>:3001/api/v1

npm run build

# Upload to S3 bucket
aws s3 sync dist/ s3://$(terraform output -raw frontend_bucket_id)/

# Verify frontend can reach backend
curl -f $(terraform output -json application_urls | jq -r '.frontend_website')
```

## Cost Management

### Auto-Shutdown Features
- **Daily Shutdown**: 8 PM (saves ~50% on compute costs)
- **Daily Startup**: 8 AM  
- **Weekend Shutdown**: Entire weekends (saves ~28% on compute costs)
- **Manual Override**: Can start/stop instances manually

### Monitor Costs
```bash
# Check estimated costs
terraform output cost_optimizations

# AWS Cost Explorer
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31 --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE
```

## Troubleshooting

### Common Issues

#### 1. Health Check Failing
```bash
# Check application status
sudo systemctl status amazon-cloudwatch-agent
sudo -u beerapp pm2 status

# Check application logs
sudo tail -f /var/log/beer-awards/error.log
```

#### 2. Database Connection Issues
```bash
# Check PostgreSQL status
sudo systemctl status postgresql
sudo -u postgres psql -c "SELECT version();"

# Check database connectivity
sudo -u beerapp psql -h localhost -U postgres -d beer_awards_dev -c "SELECT 1;"
```

#### 3. Frontend Not Loading
```bash
# Check S3 bucket website configuration
aws s3api get-bucket-website --bucket $(terraform output -raw frontend_bucket_id)

# Upload default files if missing
aws s3 cp index.html s3://$(terraform output -raw frontend_bucket_id)/
```

#### 4. Direct Access Issues
```bash
# Check if EC2 security group allows traffic
aws ec2 describe-security-groups --group-ids $(terraform output -raw ec2_security_group_id)

# Test direct connectivity
curl -v http://$(terraform output -raw ec2_public_ip):3001/api/v1/health

# Check if port is accessible
telnet $(terraform output -raw ec2_public_ip) 3001
```

## Cleanup

### Destroy Infrastructure
```bash
# Destroy all resources
terraform destroy

# Confirm destruction
yes
```

### Manual Cleanup (if needed)
```bash
# Remove any remaining S3 objects
aws s3 rm s3://$(terraform output -raw frontend_bucket_id) --recursive

# Delete any remaining CloudWatch logs
aws logs delete-log-group --log-group-name $(terraform output -raw backend_log_group)
aws logs delete-log-group --log-group-name $(terraform output -raw postgres_log_group)
```

## Security Notes

⚠️ **Important Security Considerations for Production**

- **Direct Internet Access**: EC2 has public IP and receives traffic directly
- **SSH Access**: Restrict `ssh_cidr_blocks` to your IP only in production
- **HTTP Access**: Consider restricting `allowed_cidr_blocks` for production environments
- **No SSL/TLS**: This setup uses HTTP only - add HTTPS for production
- **Database Security**: Local PostgreSQL is not accessible from internet (good!)
- **Secrets Management**: Database passwords are auto-generated and stored in Terraform state
- **Security Groups**: Review and restrict ports as needed for your use case

### Recommended Security Improvements for Production
1. **Add CloudFront with SSL certificate** for HTTPS
2. **Use Application Load Balancer** with SSL termination
3. **Move EC2 to private subnet** with bastion host
4. **Use AWS Secrets Manager** for database credentials
5. **Enable VPC Flow Logs** for network monitoring
6. **Add WAF rules** for application protection

## Support

For issues with this infrastructure setup:
1. Check CloudWatch logs for application errors
2. Review user-data.log for installation issues
3. Verify security group and network connectivity
4. Contact Chocolandia infrastructure team

## Next Steps

### For Production Environment
1. Enable RDS with Multi-AZ deployment
2. Add CloudFront distribution
3. Implement proper backup strategy
4. Add additional monitoring and alerting
5. Enable encryption at rest and in transit
6. Implement proper CI/CD pipeline
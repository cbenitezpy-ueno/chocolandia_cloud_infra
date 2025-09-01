# 🚀 Beer Awards - Quick Start

Ultra-optimized AWS deployment in under 10 minutes.

## ⚡ One-Command Deploy

```bash
# Clone and deploy
cd /Users/cbenitez/aws_chocolandia/environments/beer-awards-dev/

# Configure (edit these values)
cat > terraform.tfvars << EOF
aws_region = "us-east-1"
owner_email = "tu-email@chocolandia.com"
ec2_key_pair_name = "beer-awards-dev-key"
allowed_cidr_blocks = ["$(curl -s https://ipv4.icanhazip.com)/32"]
ssh_cidr_blocks = ["$(curl -s https://ipv4.icanhazip.com)/32"]
EOF

# Deploy everything
terraform init && terraform apply -auto-approve
```

## ✅ Verify Deployment (2 minutes)

```bash
# Test backend API
curl http://$(terraform output -raw ec2_public_ip):3001/api/v1/health

# Expected: {"status":"ok","timestamp":"...","service":"beer-awards-backend"}
```

```bash
# Test frontend
curl -I $(terraform output -raw frontend_website_url)

# Expected: HTTP/1.1 200 OK
```

```bash  
# SSH access
ssh -i ~/.ssh/beer-awards-dev-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
sudo beer-awards-status
```

## 📋 What You Get

- ✅ **EC2 t3.micro** with public IP
- ✅ **PostgreSQL 15** running locally
- ✅ **Node.js + PM2** application server
- ✅ **S3 static website** for frontend
- ✅ **Health monitoring** dashboard
- ✅ **Auto-shutdown** (8PM-8AM) for cost savings
- ✅ **Complete logging** via CloudWatch

## 💰 Cost

- **With free tier**: $5-8/month
- **Without free tier**: $8-12/month
- **Savings vs full setup**: 90%+

## 🔗 Access URLs

After deployment, get your URLs:

```bash
# Show all URLs
terraform output application_urls

# Direct access
echo "Backend: http://$(terraform output -raw ec2_public_ip):3001"
echo "Frontend: $(terraform output -raw frontend_website_url)"
echo "API: http://$(terraform output -raw ec2_public_ip):3001/api/v1"
echo "Health: http://$(terraform output -raw ec2_public_ip):3001/api/v1/health"
```

## 🛠️ Deploy Your App

```bash
# SSH to server
ssh -i ~/.ssh/beer-awards-dev-key.pem ec2-user@$(terraform output -raw ec2_public_ip)

# Replace placeholder app
sudo -u beerapp bash
cd /opt/beer-awards
pm2 stop all

# Upload your code here (git clone, scp, etc.)
# Then restart:
pm2 start ecosystem.config.js
```

## 🧹 Clean Up

```bash
terraform destroy -auto-approve
```

## 📚 Need Help?

- **Full Guide**: [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
- **Architecture**: [../modules/beer-awards-infrastructure/ARCHITECTURE_SUMMARY.md](../modules/beer-awards-infrastructure/ARCHITECTURE_SUMMARY.md)
- **Troubleshooting**: [README.md](./README.md#troubleshooting)

---

**Account**: 353385936485 (Chocolandia Dev)  
**Time**: ~5 minutes deploy + 2 minutes verify  
**Cost**: $5-8/month  
**Support**: Chocolandia DevOps Team
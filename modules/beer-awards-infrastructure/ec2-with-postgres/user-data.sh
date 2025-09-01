#!/bin/bash

# Beer Awards EC2 User Data Script
# Installs PostgreSQL, Node.js, and deploys the Beer Awards backend
# For Amazon Linux 2023

set -e

# Log everything
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Started Beer Awards setup at $(date)"

# Update system
echo "=== Updating system packages ==="
dnf update -y

# Install PostgreSQL 15
echo "=== Installing PostgreSQL 15 ==="
dnf install -y postgresql15-server postgresql15-contrib

# Initialize PostgreSQL
echo "=== Initializing PostgreSQL ==="
postgresql-setup --initdb

# Configure PostgreSQL to start on boot
systemctl enable postgresql
systemctl start postgresql

# Configure PostgreSQL authentication
echo "=== Configuring PostgreSQL authentication ==="
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${db_password}';"

# Create application database
echo "=== Creating application database ==="
sudo -u postgres createdb ${db_name}

# Configure PostgreSQL for application access
cat >> /var/lib/pgsql/data/pg_hba.conf << EOF
# Beer Awards application access
host    ${db_name}    ${db_username}    127.0.0.1/32    md5
host    ${db_name}    ${db_username}    ::1/128         md5
EOF

# Configure PostgreSQL connection settings
cat >> /var/lib/pgsql/data/postgresql.conf << EOF
# Beer Awards configuration
listen_addresses = 'localhost'
port = 5432
max_connections = 100
shared_buffers = 128MB
EOF

# Restart PostgreSQL to apply configuration
systemctl restart postgresql

# Install Node.js 18 LTS
echo "=== Installing Node.js 18 LTS ==="
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
dnf install -y nodejs

# Install pnpm globally
echo "=== Installing pnpm ==="
npm install -g pnpm

# Install Git
echo "=== Installing Git ==="
dnf install -y git

# Install PM2 for process management
echo "=== Installing PM2 ==="
npm install -g pm2

# Install CloudWatch agent for logging
echo "=== Installing CloudWatch agent ==="
dnf install -y amazon-cloudwatch-agent

# Create application user
echo "=== Creating application user ==="
useradd -m -s /bin/bash beerapp
usermod -aG wheel beerapp

# Create application directory
echo "=== Setting up application directory ==="
mkdir -p /opt/beer-awards
chown beerapp:beerapp /opt/beer-awards

# Setup environment file
echo "=== Creating environment configuration ==="
cat > /opt/beer-awards/.env << EOF
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=${db_name}
DB_USER=${db_username}
DB_PASS=${db_password}

# Application Configuration
NODE_ENV=production
PORT=${backend_port}
JWT_SECRET=${jwt_secret}
FRONTEND_URL=${frontend_url}

# New Relic Configuration (if provided)
${new_relic_license_key != "" ? "BEER_NEW_RELIC_INGEST=${new_relic_license_key}" : ""}
${new_relic_app_name != "" ? "BEER_NEW_RELIC_APP_NAME=${new_relic_app_name}" : ""}
EOF

chown beerapp:beerapp /opt/beer-awards/.env
chmod 600 /opt/beer-awards/.env

# Clone and setup application (placeholder - will be updated with actual repo)
echo "=== Setting up Beer Awards application ==="
sudo -u beerapp bash << 'USEREOF'
cd /opt/beer-awards

# For now, create a basic health check server
# This will be replaced with actual application deployment
cat > server.js << 'APPEOF'
const http = require('http');
const url = require('url');

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }
  
  if (parsedUrl.pathname === '/api/v1/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'beer-awards-backend',
      database: 'postgresql-local'
    }));
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

const port = process.env.PORT || ${backend_port};
server.listen(port, '0.0.0.0', () => {
  console.log(`Beer Awards backend listening on port $${port}`);
  console.log(`Health check: http://localhost:$${port}/api/v1/health`);
});
APPEOF

# Install dependencies (minimal for now)
npm init -y
npm install

USEREOF

# Create PM2 ecosystem file
echo "=== Creating PM2 configuration ==="
cat > /opt/beer-awards/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'beer-awards-backend',
    script: 'server.js',
    cwd: '/opt/beer-awards',
    user: 'beerapp',
    instances: 1,
    exec_mode: 'fork',
    watch: false,
    max_memory_restart: '500M',
    env: {
      NODE_ENV: 'production'
    },
    log_file: '/var/log/beer-awards/app.log',
    out_file: '/var/log/beer-awards/out.log',
    error_file: '/var/log/beer-awards/error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
  }]
};
EOF

chown beerapp:beerapp /opt/beer-awards/ecosystem.config.js

# Create log directory
mkdir -p /var/log/beer-awards
chown beerapp:beerapp /var/log/beer-awards

# Start application with PM2
echo "=== Starting Beer Awards application ==="
sudo -u beerapp bash << 'USEREOF'
cd /opt/beer-awards
pm2 start ecosystem.config.js
pm2 save
USEREOF

# Setup PM2 to start on boot
env PATH=$PATH:/usr/bin pm2 startup systemd -u beerapp --hp /home/beerapp

# Configure CloudWatch agent
echo "=== Configuring CloudWatch agent ==="
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/beer-awards/app.log",
            "log_group_name": "/aws/ec2/${name_prefix}/backend",
            "log_stream_name": "{instance_id}/application"
          },
          {
            "file_path": "/var/log/postgresql/postgresql*.log",
            "log_group_name": "/aws/ec2/${name_prefix}/postgresql",
            "log_stream_name": "{instance_id}/postgresql"
          },
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/aws/ec2/${name_prefix}/backend",
            "log_stream_name": "{instance_id}/user-data"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "BeerAwards/EC2",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_iowait"],
        "metrics_collection_interval": 300,
        "totalcpu": false
      },
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 300,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 300
      }
    }
  }
}
EOF

# Start CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Setup logrotate for application logs
cat > /etc/logrotate.d/beer-awards << 'EOF'
/var/log/beer-awards/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    postrotate
        sudo -u beerapp pm2 reloadLogs
    endscript
}
EOF

# Final system optimizations
echo "=== Applying system optimizations ==="

# Optimize PostgreSQL for small instance
sudo -u postgres psql -d ${db_name} -c "ALTER SYSTEM SET shared_buffers = '64MB';"
sudo -u postgres psql -d ${db_name} -c "ALTER SYSTEM SET effective_cache_size = '256MB';"
sudo -u postgres psql -d ${db_name} -c "ALTER SYSTEM SET maintenance_work_mem = '16MB';"
sudo -u postgres psql -d ${db_name} -c "SELECT pg_reload_conf();"

# Setup simple firewall rules
echo "=== Configuring basic firewall ==="
dnf install -y firewalld
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=${backend_port}/tcp
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# Create status script for health monitoring
cat > /usr/local/bin/beer-awards-status << 'EOF'
#!/bin/bash
echo "=== Beer Awards System Status ==="
echo "Date: $(date)"
echo ""

echo "=== Application Status ==="
sudo -u beerapp pm2 status

echo ""
echo "=== Database Status ==="
systemctl is-active postgresql

echo ""
echo "=== System Resources ==="
free -h
df -h /

echo ""
echo "=== Recent Application Logs ==="
tail -n 5 /var/log/beer-awards/app.log 2>/dev/null || echo "No application logs yet"

echo ""
echo "=== Health Check ==="
curl -s http://localhost:${backend_port}/api/v1/health || echo "Health check failed"
EOF

chmod +x /usr/local/bin/beer-awards-status

echo "=== Beer Awards setup completed successfully ==="
echo "Application URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):${backend_port}/api/v1/health"
echo "Run 'beer-awards-status' to check system status"
echo "Logs available at: /var/log/beer-awards/"
echo "Setup completed at $(date)"
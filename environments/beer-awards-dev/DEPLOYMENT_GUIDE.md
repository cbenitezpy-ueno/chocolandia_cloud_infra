# Beer Awards Ultra-Optimized Deployment Guide

Guía completa para desplegar la infraestructura ultra-optimizada de Beer Awards en AWS.

## 🎯 Resumen de la Arquitectura

### Infraestructura Ultra-Simplificada
- **1 VPC** con 1 subnet pública únicamente
- **1 EC2 t3.micro** con IP pública para acceso directo
- **PostgreSQL local** corriendo en el EC2
- **S3 Static Website** para el frontend
- **CloudWatch básico** para logs

### Costos Optimizados
- **Sin ALB**: Ahorro de $16/mes
- **Sin NAT Gateway**: Ahorro de $15-45/mes
- **Sin RDS**: Ahorro de $20-30/mes
- **Sin CloudFront**: Ahorro de $10-20/mes
- **Costo total**: $5-8/mes (con free tier)

## 🚀 Despliegue Paso a Paso

### Paso 1: Preparación de AWS

#### 1.1 Verificar Acceso a la Cuenta
```bash
# Configurar AWS CLI para cuenta de desarrollo
aws configure
# Account ID: 353385936485 (Chocolandia Organization)

# Verificar acceso
aws sts get-caller-identity
```

#### 1.2 Crear Key Pair para EC2
```bash
# Opción 1: Via CLI
aws ec2 create-key-pair --key-name beer-awards-dev-key \
  --query 'KeyMaterial' --output text > ~/.ssh/beer-awards-dev-key.pem

# Configurar permisos
chmod 400 ~/.ssh/beer-awards-dev-key.pem

# Opción 2: Via Console AWS
# 1. Ir a EC2 → Key Pairs
# 2. Create Key Pair → "beer-awards-dev-key" 
# 3. Download .pem file
```

### Paso 2: Configuración de Variables

#### 2.1 Copiar Archivo de Ejemplo
```bash
cd /Users/cbenitez/aws_chocolandia/environments/beer-awards-dev/
cp terraform.tfvars.example terraform.tfvars
```

#### 2.2 Editar Variables Críticas
```bash
vi terraform.tfvars
```

**Variables obligatorias:**
```hcl
# AWS Configuration
aws_region = "us-east-1"  # Cambiar si es necesario
owner_email = "tu-email@chocolandia.com"

# EC2 Key Pair (OBLIGATORIO)
ec2_key_pair_name = "beer-awards-dev-key"

# Security (CRÍTICO)
allowed_cidr_blocks = ["TU_IP_PUBLICA/32"]  # ¡Restringir a tu IP!
ssh_cidr_blocks = ["TU_IP_PUBLICA/32"]      # ¡Restringir a tu IP!

# New Relic (Opcional)
# new_relic_license_key = "tu-license-key-aqui"
```

### Paso 3: Despliegue de Infraestructura

#### 3.1 Inicializar Terraform
```bash
terraform init
```

#### 3.2 Planificar Despliegue
```bash
terraform plan
```

**Recursos que se crearán:**
- 1 VPC con 1 subnet pública
- 1 Internet Gateway
- 1 Route Table
- 1 Security Group
- 1 EC2 instance t3.micro
- 1 S3 bucket para frontend
- 2 CloudWatch Log Groups

#### 3.3 Ejecutar Despliegue
```bash
terraform apply
```

**Tiempo estimado:** 3-5 minutos

#### 3.4 Obtener Información de Despliegue
```bash
# URLs de acceso
terraform output application_urls

# Información detallada
terraform output infrastructure_details

# Información sensible (passwords)
terraform output -json connection_info
```

### Paso 4: Verificación Post-Despliegue

#### 4.1 Verificar EC2 y Aplicación
```bash
# Obtener IP pública
PUBLIC_IP=$(terraform output -raw ec2_public_ip)

# Probar conectividad
ping -c 3 $PUBLIC_IP

# Probar aplicación (puede tardar 2-3 minutos en iniciar)
curl http://$PUBLIC_IP:3001/api/v1/health

# Respuesta esperada:
# {"status":"ok","timestamp":"...","service":"beer-awards-backend","database":"postgresql-local"}
```

#### 4.2 Verificar Frontend S3
```bash
# Obtener URL del frontend
FRONTEND_URL=$(terraform output -raw frontend_website_url)

# Abrir en navegador o probar
curl -I $FRONTEND_URL

echo "Frontend disponible en: $FRONTEND_URL"
```

#### 4.3 SSH al EC2 para Revisión Detallada
```bash
# Conectar via SSH
ssh -i ~/.ssh/beer-awards-dev-key.pem ec2-user@$PUBLIC_IP

# Una vez conectado, verificar servicios
sudo beer-awards-status

# Verificar logs de instalación
sudo tail -f /var/log/user-data.log

# Verificar aplicación
sudo -u beerapp pm2 status

# Verificar PostgreSQL
sudo systemctl status postgresql
sudo -u postgres psql -c "SELECT version();"

# Salir del SSH
exit
```

## 🔧 Configuración de la Aplicación

### Paso 5: Desplegar Aplicación Real

#### 5.1 SSH al Servidor
```bash
ssh -i ~/.ssh/beer-awards-dev-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
```

#### 5.2 Reemplazar Aplicación Placeholder
```bash
# Cambiar a usuario de aplicación
sudo -u beerapp bash

# Ir al directorio de aplicación
cd /opt/beer-awards

# Detener aplicación placeholder
pm2 stop all

# Respaldar configuración
cp ecosystem.config.js ecosystem.config.js.backup

# Clonar aplicación real (reemplazar con tu repo)
rm -rf server.js package*.json
git clone https://github.com/tu-org/beer-awards-backend.git .

# O subir código manualmente
# scp -i ~/.ssh/beer-awards-dev-key.pem -r ./backend/* ec2-user@$PUBLIC_IP:/opt/beer-awards/
```

#### 5.3 Instalar y Configurar Aplicación
```bash
# Instalar dependencias
pnpm install

# Configurar variables de entorno (ya están en .env)
cat /opt/beer-awards/.env

# Ejecutar migraciones de base de datos
pnpm db:migrate

# Actualizar ecosystem.config.js si es necesario
vi ecosystem.config.js

# Iniciar aplicación
pm2 start ecosystem.config.js
pm2 save

# Verificar
pm2 status
pm2 logs
```

### Paso 6: Configurar Frontend

#### 6.1 Actualizar Variables de Frontend
```bash
# En tu máquina local, actualizar variables de entorno del frontend
cd /path/to/beer-awards-frontend

# Actualizar .env.production
echo "NEXT_PUBLIC_API_URL=http://$(terraform output -raw ec2_public_ip):3001/api/v1" > .env.production

# Construir frontend
pnpm build
```

#### 6.2 Subir Frontend a S3
```bash
# Subir archivos construidos
aws s3 sync dist/ s3://$(terraform output -raw frontend_bucket_id)/ --delete

# Verificar que se subió correctamente
aws s3 ls s3://$(terraform output -raw frontend_bucket_id)/

# Probar frontend
curl -I $(terraform output -raw frontend_website_url)
```

## 📊 Monitoreo y Mantenimiento

### Logs y Monitoreo

#### Ver Logs de Aplicación
```bash
# Logs en tiempo real
aws logs tail /aws/ec2/beer-awards-dev/backend --follow

# Logs de PostgreSQL
aws logs tail /aws/ec2/beer-awards-dev/postgresql --follow

# O via SSH
ssh -i ~/.ssh/beer-awards-dev-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
sudo tail -f /var/log/beer-awards/app.log
```

#### Monitoreo de Costos
```bash
# Ver costos estimados
terraform output cost_optimizations

# Monitorear costos en AWS Console
# Billing → Cost Explorer
```

### Gestión de Auto-Shutdown

#### Verificar Programación
```bash
# Ver configuración actual
terraform output -json cost_optimizations

# Las instancias se apagan automáticamente:
# - Diariamente a las 8 PM
# - Se encienden a las 8 AM
# - Se apagan los fines de semana
```

#### Control Manual de Instancias
```bash
# Parar instancia manualmente
aws ec2 stop-instances --instance-ids $(terraform output -raw ec2_instance_id)

# Iniciar instancia manualmente
aws ec2 start-instances --instance-ids $(terraform output -raw ec2_instance_id)

# Verificar estado
aws ec2 describe-instances --instance-ids $(terraform output -raw ec2_instance_id) \
  --query 'Reservations[0].Instances[0].State.Name'
```

## 🔒 Mejores Prácticas de Seguridad

### Configuración de Seguridad Básica

#### 1. Restringir Acceso por IP
```bash
# En terraform.tfvars, cambiar:
allowed_cidr_blocks = ["TU_IP/32"]  # Solo tu IP
ssh_cidr_blocks = ["TU_IP/32"]      # Solo tu IP

# Aplicar cambios
terraform apply
```

#### 2. Configurar Firewall en EC2
```bash
ssh -i ~/.ssh/beer-awards-dev-key.pem ec2-user@$(terraform output -raw ec2_public_ip)

# Verificar firewall
sudo firewall-cmd --list-all

# Personalizar reglas si es necesario
sudo firewall-cmd --permanent --remove-service=dhcpv6-client
sudo firewall-cmd --reload
```

#### 3. Actualizar Passwords
```bash
# Obtener password actual de BD
terraform output -json connection_info | jq -r '.database.password'

# Conectar y cambiar password
ssh -i ~/.ssh/beer-awards-dev-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'nuevo-password-seguro';"

# Actualizar .env
sudo vi /opt/beer-awards/.env

# Reiniciar aplicación
sudo -u beerapp pm2 restart all
```

## 🚨 Solución de Problemas

### Problemas Comunes

#### 1. Aplicación No Responde
```bash
# Verificar estado del EC2
aws ec2 describe-instances --instance-ids $(terraform output -raw ec2_instance_id)

# SSH y verificar servicios
ssh -i ~/.ssh/beer-awards-dev-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
sudo beer-awards-status
sudo -u beerapp pm2 restart all
```

#### 2. No Se Puede Conectar por SSH
```bash
# Verificar security group
aws ec2 describe-security-groups --group-ids $(terraform output -raw ec2_security_group_id)

# Verificar tu IP pública
curl -s https://ipv4.icanhazip.com

# Actualizar terraform.tfvars con tu IP actual
terraform apply
```

#### 3. Base de Datos No Conecta
```bash
ssh -i ~/.ssh/beer-awards-dev-key.pem ec2-user@$(terraform output -raw ec2_public_ip)

# Verificar PostgreSQL
sudo systemctl status postgresql
sudo systemctl restart postgresql

# Probar conexión
sudo -u postgres psql -c "SELECT 1;"
```

#### 4. Frontend No Carga
```bash
# Verificar bucket S3
aws s3 ls s3://$(terraform output -raw frontend_bucket_id)/

# Re-subir archivos
aws s3 sync dist/ s3://$(terraform output -raw frontend_bucket_id)/ --delete

# Verificar configuración de website
aws s3api get-bucket-website --bucket $(terraform output -raw frontend_bucket_id)
```

## 🔄 Actualización y Limpieza

### Actualizar Infraestructura
```bash
# Después de cambios en el código Terraform
terraform plan
terraform apply
```

### Backup de Datos (Importante)
```bash
# Backup de base de datos antes de cambios importantes
ssh -i ~/.ssh/beer-awards-dev-key.pem ec2-user@$(terraform output -raw ec2_public_ip)

# Crear backup
sudo -u postgres pg_dump beer_awards_dev > /tmp/backup-$(date +%Y%m%d).sql

# Descargar backup
scp -i ~/.ssh/beer-awards-dev-key.pem \
  ec2-user@$(terraform output -raw ec2_public_ip):/tmp/backup-$(date +%Y%m%d).sql \
  ./backup-$(date +%Y%m%d).sql
```

### Destruir Infraestructura
```bash
# ⚠️ CUIDADO: Esto elimina toda la infraestructura
terraform destroy

# Confirmar con 'yes'
```

## 📋 Checklist de Despliegue

### Pre-Despliegue
- [ ] AWS CLI configurado
- [ ] Terraform instalado
- [ ] Key Pair creado
- [ ] Variables configuradas en terraform.tfvars
- [ ] IPs restringidas en security groups

### Despliegue
- [ ] terraform init ejecutado
- [ ] terraform plan revisado
- [ ] terraform apply exitoso
- [ ] Health check OK (http://IP:3001/api/v1/health)
- [ ] SSH conecta correctamente
- [ ] Frontend S3 accesible

### Post-Despliegue
- [ ] Aplicación real desplegada
- [ ] Base de datos migrada
- [ ] Frontend actualizado y subido
- [ ] Logs monitoreándose
- [ ] Auto-shutdown configurado
- [ ] Backup de datos realizado

## 🎉 ¡Despliegue Completado!

Tu infraestructura Beer Awards ultra-optimizada está lista:

- **Backend**: http://$(terraform output -raw ec2_public_ip):3001
- **API**: http://$(terraform output -raw ec2_public_ip):3001/api/v1
- **Frontend**: $(terraform output -raw frontend_website_url)
- **Costo**: $5-8/mes (con free tier)
- **Ahorro**: 90%+ vs setup completo

¡Felicidades! Has desplegado una infraestructura AWS ultra-eficiente para desarrollo. 🚀
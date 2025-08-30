# AWS Chocolandia - Multi-Account Organization

Infrastructure as Code para la estructura organizacional multi-cuenta de AWS usando Terraform.

## Estructura del Proyecto

```
├── core/           # Core OU y cuentas centralizadas
├── production/     # Production OU y cuentas de aplicaciones
├── staging/        # Staging OU y cuentas de aplicaciones  
├── development/    # Development OU y cuentas de aplicaciones
├── modules/        # Módulos reutilizables de Terraform
└── terraform.tf    # Configuración principal de providers
```

## Cómo usar

1. **Inicializar Terraform:**
   ```bash
   terraform init
   ```

2. **Planificar cambios:**
   ```bash
   # Para todas las carpetas
   terraform plan -target=module.core
   terraform plan -target=module.production
   # etc...
   ```

3. **Aplicar cambios:**
   ```bash
   terraform apply
   ```

## Email Configuration

Todas las cuentas usan el mismo email: `chocolim@icloud.com`
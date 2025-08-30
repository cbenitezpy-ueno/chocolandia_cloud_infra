# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AWS multi-account organization structure managed with Terraform. Creates a hierarchical organization with separate accounts for different environments and applications to enable cost separation and environment isolation.

## Organizational Structure

```
Root Organization
├── Core OU (Centralized accounts)
│   ├── Security Account
│   ├── Logging Account
│   └── Shared Services Account
├── Production OU
│   ├── App1-Prod Account
│   └── App2-Prod Account
├── Staging OU
│   ├── App1-Staging Account
│   └── App2-Staging Account
└── Development OU
    ├── App1-Dev Account
    └── App2-Dev Account
```

## Folder Structure

- `core/` - Core organizational units and shared services accounts
- `production/` - Production environment accounts
- `staging/` - Staging environment accounts  
- `development/` - Development environment accounts
- `modules/` - Reusable Terraform modules

## Development Commands

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```
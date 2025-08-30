data "aws_organizations_organization" "main" {}

# Core Organizational Unit
resource "aws_organizations_organizational_unit" "core" {
  name      = "Core"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

# Security Account
resource "aws_organizations_account" "security" {
  name                       = "Security"
  email                      = "chocolim+security@icloud.com"
  parent_id                  = aws_organizations_organizational_unit.core.id
  close_on_deletion          = false
  create_govcloud            = false
  iam_user_access_to_billing = "ALLOW"

  tags = {
    Environment = "core"
    Purpose     = "security"
  }
}

# Logging Account
resource "aws_organizations_account" "logging" {
  name                       = "Logging"
  email                      = "chocolim+logging@icloud.com"
  parent_id                  = aws_organizations_organizational_unit.core.id
  close_on_deletion          = false
  create_govcloud            = false
  iam_user_access_to_billing = "ALLOW"

  tags = {
    Environment = "core"
    Purpose     = "logging"
  }
}

# Shared Services Account
resource "aws_organizations_account" "shared_services" {
  name                       = "Shared-Services"
  email                      = "chocolim+shared@icloud.com"
  parent_id                  = aws_organizations_organizational_unit.core.id
  close_on_deletion          = false
  create_govcloud            = false
  iam_user_access_to_billing = "ALLOW"

  tags = {
    Environment = "core"
    Purpose     = "shared-services"
  }
}
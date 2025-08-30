data "aws_organizations_organization" "main" {}

# Development Organizational Unit
resource "aws_organizations_organizational_unit" "development" {
  name      = "Development"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

# BeerSystem Development Account
resource "aws_organizations_account" "beersystem_dev" {
  name                       = "BeerSystem-Development"
  email                      = "chocolim@icloud.com"
  parent_id                  = aws_organizations_organizational_unit.development.id
  close_on_deletion          = false
  create_govcloud            = false
  iam_user_access_to_billing = "ALLOW"

  tags = {
    Environment = "development"
    Application = "beersystem"
  }
}
data "aws_organizations_organization" "main" {}

# Production Organizational Unit
resource "aws_organizations_organizational_unit" "production" {
  name      = "Production"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

# BeerSystem Production Account
resource "aws_organizations_account" "beersystem_prod" {
  name                       = "BeerSystem-Production"
  email                      = "chocolim@icloud.com"
  parent_id                  = aws_organizations_organizational_unit.production.id
  close_on_deletion          = false
  create_govcloud            = false
  iam_user_access_to_billing = "ALLOW"

  tags = {
    Environment = "production"
    Application = "beersystem"
  }
}
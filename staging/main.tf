data "aws_organizations_organization" "main" {}

# Staging Organizational Unit
resource "aws_organizations_organizational_unit" "staging" {
  name      = "Staging"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

# BeerSystem Staging Account
resource "aws_organizations_account" "beersystem_staging" {
  name                       = "BeerSystem-Staging"
  email                      = "chocolim+staging@icloud.com"
  parent_id                  = aws_organizations_organizational_unit.staging.id
  close_on_deletion          = false
  create_govcloud            = false
  iam_user_access_to_billing = "ALLOW"

  tags = {
    Environment = "staging"
    Application = "beersystem"
  }
}
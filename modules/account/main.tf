resource "aws_organizations_account" "this" {
  name                       = var.name
  email                      = var.email
  parent_id                  = var.parent_id
  close_on_deletion          = var.close_on_deletion
  create_govcloud            = var.create_govcloud
  iam_user_access_to_billing = var.iam_user_access_to_billing

  tags = var.tags
}
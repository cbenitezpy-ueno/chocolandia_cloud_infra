# Global Budget for Chocolandia Organization
resource "aws_budgets_budget" "chocolandia_monthly" {
  name         = "chocolandia-monthly-budget"
  budget_type  = "COST"
  limit_amount = "30"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  time_period_start = "2025-09-01_00:00"

  cost_filter {
    name   = "LinkedAccount"
    values = [data.aws_organizations_organization.main.master_account_id]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = ["chocolim@icloud.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["chocolim@icloud.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 50
    threshold_type            = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["chocolim@icloud.com"]
  }
}

# Data source for organization info
data "aws_organizations_organization" "main" {}
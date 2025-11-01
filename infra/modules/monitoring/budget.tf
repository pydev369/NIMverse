resource "aws_budgets_budget" "dev_budget" {
  name = "DevBudget"
  budget_type = "COST"
  limit_amount = var.monthly_budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    threshold = 50
    threshold_type = "PERCENTAGE"
    notification_type = "ACTUAL"

    subscriber {
      subscription_type = "EMAIL"
      address = var.alert_email
    }
  }

  notification {
    comparison_operator = "GREATER_THAN"
    threshold = 80
    threshold_type = "PERCENTAGE"
    notification_type = "ACTUAL"

    subscriber {
      subscription_type = "EMAIL"
      address = var.alert_email
    }
  }
}

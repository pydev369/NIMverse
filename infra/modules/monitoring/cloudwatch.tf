resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "EstimatedChargesOverLimit"
  namespace           = "AWS/Billing"
  metric_name         = "EstimatedCharges"
  dimensions          = { Currency = "USD" }
  statistic           = "Maximum"
  period              = 21600
  evaluation_periods  = 1
  threshold           = var.monthly_budget_limit * 0.5
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_description   = "Alert when estimated charges exceed 50% budget"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

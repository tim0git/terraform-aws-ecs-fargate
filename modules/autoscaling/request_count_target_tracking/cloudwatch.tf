resource "aws_cloudwatch_log_group" "autoscaling_lambda" {
  count             = var.create ? 1 : 0
  name              = "/aws/lambda/${var.application_name}-target-tracking"
  retention_in_days = var.log_group_retention_in_days
  tags              = var.tags
}


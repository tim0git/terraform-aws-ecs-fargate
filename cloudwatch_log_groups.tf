resource "aws_cloudwatch_log_group" "ecs_service" {
  name              = "ecs/${var.application_name}"
  retention_in_days = var.log_group_retention_in_days
  tags              = var.tags
}


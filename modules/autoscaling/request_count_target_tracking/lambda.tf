resource "aws_lambda_function" "autoscaling" {
  count         = var.create ? 1 : 0
  function_name = "${var.application_name}-target-tracking"
  role          = aws_iam_role.lambda[0].arn
  runtime       = "python3.9"
  handler       = "lambda.lambda_handler"
  filename      = "${path.module}/lambda.zip"
  timeout       = 15
  memory_size   = 128
  environment {
    variables = {
      ecs_cluster_name       = var.ecs_cluster_name
      ecs_service_name       = var.ecs_service_name
      autoscale_policy_name  = "${var.application_name}-target-tracking"
      autoscale_target_value = var.autoscale_target_value
      minimum_capacity       = var.scale_target_min_capacity
      maximum_capacity       = var.scale_target_max_capacity
      load_balancer_name     = var.load_balancer_name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.autoscaling_lambda[0],
  ]

  tags = var.tags
}

resource "aws_lambda_permission" "autoscaling" {
  count         = var.create ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.autoscaling[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.autoscaling[0].arn
}

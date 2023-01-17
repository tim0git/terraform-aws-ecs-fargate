locals {
  load_balancer_event = templatefile("${path.module}/resources/deploy-pipeline-modify-load-balancer-event.json", {
    codedeploy_iam_role_arn = var.code_deploy_iam_role_arn
  })
}

resource "aws_cloudwatch_event_rule" "autoscaling" {
  count         = var.create ? 1 : 0
  name          = "${var.application_name}-autoscaling-target-update-event"
  description   = "Amazon CloudWatch Events rule to automatically switch autoscaling alarm following a target group change at the load balancer"
  event_pattern = local.load_balancer_event

  tags = var.tags
}
resource "aws_cloudwatch_event_target" "autoscaling" {
  count     = var.create ? 1 : 0
  rule      = aws_cloudwatch_event_rule.autoscaling[0].name
  target_id = "${var.application_name}-autoscaling-target-update"
  arn       = aws_lambda_function.autoscaling[0].arn
}

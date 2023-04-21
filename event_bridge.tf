locals {
  codecommit_event = templatefile("${path.module}/resources/codecommit-source-event.json", {
    codecommit_repository_arn = try(aws_codecommit_repository.this[0].arn, "")
  })

  ecr_event = templatefile("${path.module}/resources/ecr-source-event.json", {
    ecr_repository_name = local.ecr_repository_name
  })

  task_failed_health_check = templatefile("${path.module}/resources/task-failed-health-check-event.json", {
    application_name = var.application_name,
    cluster_arn      = data.aws_ecs_cluster.this.arn
  })

  ecs_service_name = var.enable_pipeline ? aws_ecs_service.pipeline_enabled[0].name : aws_ecs_service.pipeline_disabled[0].name
  ecs_service_id = var.enable_pipeline ? aws_ecs_service.pipeline_enabled[0].id : aws_ecs_service.pipeline_disabled[0].id
}

resource "aws_cloudwatch_event_rule" "ecr" {
  count         = var.enable_pipeline ? 1 : 0
  name          = "${var.application_name}-ecr-event"
  description   = "Amazon CloudWatch Events rule to automatically start your pipeline when a change occurs in the Amazon ECR tag"
  event_pattern = local.ecr_event
  depends_on    = [aws_codepipeline.this[0]]
}
resource "aws_cloudwatch_event_target" "ecr" {
  count     = var.enable_pipeline ? 1 : 0
  rule      = aws_cloudwatch_event_rule.ecr[0].name
  target_id = "${var.application_name}-ecr-target"
  arn       = aws_codepipeline.this[0].arn
  role_arn  = aws_iam_role.event_bridge[0].arn
}

resource "aws_cloudwatch_event_rule" "codecommit" {
  count         = var.enable_pipeline ? 1 : 0
  name          = "${var.application_name}-codecommit-event"
  description   = "Amazon CloudWatch Events rule to automatically start your pipeline when a change occurs in the Amazon CodeCommit"
  event_pattern = local.codecommit_event
}
resource "aws_cloudwatch_event_target" "codecommit" {
  count     = var.enable_pipeline ? 1 : 0
  rule      = aws_cloudwatch_event_rule.codecommit[0].name
  target_id = "${var.application_name}-codecommit-target"
  arn       = aws_codepipeline.this[0].arn
  role_arn  = aws_iam_role.event_bridge[0].arn
}

resource "aws_cloudwatch_event_rule" "task-failed-health-check" {
  count         = var.enable_pipeline ? 1 : 0
  name          = "${var.application_name}-task-failed-health-check-event"
  description   = "Amazon CloudWatch Events rule to automatically alarm when a container health check fails"
  event_pattern = local.task_failed_health_check
}



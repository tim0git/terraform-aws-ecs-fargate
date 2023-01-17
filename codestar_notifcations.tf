resource "aws_codestarnotifications_notification_rule" "code_commit" {
  count          = var.enable_pipeline ? 1 : 0
  status         = "ENABLED"
  detail_type    = "BASIC"
  event_type_ids = ["codecommit-repository-pull-request-created", "codecommit-repository-pull-request-merged"]

  name     = "${var.application_name}-code-commit"
  resource = aws_codecommit_repository.this[0].arn

  target {
    address = aws_sns_topic.this[0].arn
  }
}

resource "aws_codestarnotifications_notification_rule" "code_pipeline" {
  count       = var.enable_pipeline ? 1 : 0
  status      = "ENABLED"
  detail_type = "BASIC"
  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-canceled",
    "codepipeline-pipeline-pipeline-execution-resumed",
    "codepipeline-pipeline-pipeline-execution-superseded",
    "codepipeline-pipeline-manual-approval-needed",
    "codepipeline-pipeline-manual-approval-failed",
    "codepipeline-pipeline-manual-approval-succeeded",
  ]

  name     = "${var.application_name}-deploy-pipeline"
  resource = aws_codepipeline.this[0].arn

  target {
    address = aws_sns_topic.this[0].arn
  }
}

resource "aws_codestarnotifications_notification_rule" "code_deploy" {
  count       = var.enable_pipeline ? 1 : 0
  status      = "ENABLED"
  detail_type = "BASIC"
  event_type_ids = [
    "codedeploy-application-deployment-failed",
    "codedeploy-application-deployment-succeeded",
    "codedeploy-application-deployment-started"
  ]

  name     = "${var.application_name}-code-deploy"
  resource = aws_codedeploy_app.this[0].arn

  target {
    address = aws_sns_topic.this[0].arn
  }
}

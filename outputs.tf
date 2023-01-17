#ECS Service
output "aws_ecs_service_id" {
  value       = var.enable_pipeline ? aws_ecs_service.pipeline_enabled[0].id : aws_ecs_service.pipeline_disabled[0].id
  description = "The id of the ECS service"
}
output "aws_ecs_service_name" {
  value       = var.enable_pipeline ? aws_ecs_service.pipeline_enabled[0].name : aws_ecs_service.pipeline_disabled[0].name
  description = "The name of the ECS service"
}
output "aws_ecs_task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "The ARN of the ECS task definition"
}
output "aws_ecs_task_definition_revision" {
  value       = aws_ecs_task_definition.this.revision
  description = "The revision number of the ECS task definition"
}

#IAM
output "aws_iam_execution_role_arn" {
  value       = aws_iam_role.execution.arn
  description = "The ARN of the ECS Service execution role"
}
output "aws_iam_execution_role_name" {
  value       = aws_iam_role.execution.name
  description = "The name of the ECS Service execution role"
}
output "aws_iam_task_role_arn" {
  value       = aws_iam_role.task.arn
  description = "The ARN of the ECS Service task role"
}
output "aws_iam_task_role_name" {
  value       = aws_iam_role.task.name
  description = "The name of the ECS Service task role"
}
output "aws_iam_code_deploy_role_arn" {
  value       = var.enable_pipeline ? aws_iam_role.code_deploy[0].arn : ""
  description = "The ARN of the CodeDeploy role"
}
output "aws_iam_code_deploy_role_name" {
  value       = var.enable_pipeline ? aws_iam_role.code_deploy[0].name : ""
  description = "The name of the CodeDeploy role"
}
output "aws_code_pipeline_role_arn" {
  value       = var.enable_pipeline ? aws_iam_role.code_pipeline[0].arn : ""
  description = "The ARN of the CodePipeline role"
}
output "aws_code_pipeline_role_name" {
  value       = var.enable_pipeline ? aws_iam_role.code_pipeline[0].name : ""
  description = "The name of the CodePipeline role"
}
output "aws_code_event_bridge_role_arn" {
  value       = var.enable_pipeline ? aws_iam_role.event_bridge[0].arn : ""
  description = "The ARN of the CodeEventBridge role"
}
output "aws_code_event_bridge_role_name" {
  value       = var.enable_pipeline ? aws_iam_role.event_bridge[0].name : ""
  description = "The name of the CodeEventBridge role"
}

#AutoScaling
output "aws_scale_down_policy_arn" {
  value       = var.enable_autoscaling ? module.cpu_autoscaling.scale_down_policy_arn : ""
  description = "ARN of the scale down policy"
}
output "aws_scale_up_policy_arn" {
  value       = var.enable_autoscaling ? module.cpu_autoscaling.scale_up_policy_arn : ""
  description = "ARN of the scale up policy"
}
output "aws_metric_alarm_cpu_high_arn" {
  value       = var.enable_autoscaling ? module.cpu_autoscaling.metric_alarm_cpu_high_arn : ""
  description = "ARN of the CPU high metric alarm"
}
output "aws_metric_alarm_cpu_low_arn" {
  value       = var.enable_autoscaling ? module.cpu_autoscaling.metric_alarm_cpu_low_arn : ""
  description = "ARN of the CPU low metric alarm"
}
output "aws_scale_target_id" {
  value       = var.enable_autoscaling ? module.cpu_autoscaling.scale_target_id : ""
  description = "ID of the scale target"
}

#ALB
output "aws_lb_target_group_blue_arn" {
  value       = local.enable_load_balancing ? aws_lb_target_group.blue[0].arn : ""
  description = "The ARN of the blue target group"
}
output "aws_lb_target_group_blue_id" {
  value       = local.enable_load_balancing ? aws_lb_target_group.blue[0].id : ""
  description = "The ID of the blue target group"
}
output "aws_lb_target_group_blue_name" {
  value       = local.enable_load_balancing ? aws_lb_target_group.blue[0].name : ""
  description = "The name of the blue target group"
}
output "aws_lb_target_group_green_arn" {
  value       = var.enable_pipeline ? aws_lb_target_group.green[0].arn : ""
  description = "The ARN of the green target group"
}
output "aws_lb_target_group_green_id" {
  value       = var.enable_pipeline ? aws_lb_target_group.green[0].id : ""
  description = "The ID of the green target group"
}
output "aws_lb_target_group_green_name" {
  value       = var.enable_pipeline ? aws_lb_target_group.green[0].name : ""
  description = "The name of the green target group"
}
output "aws_lb_listener_rule_listener_arn" {
  value       = local.enable_load_balancing ? aws_lb_listener_rule.this[0].arn : ""
  description = "The ARN of the listener rule"
}
output "aws_lb_listener_rule_listener_id" {
  value       = local.enable_load_balancing ? aws_lb_listener_rule.this[0].id : ""
  description = "The ID of the listener rule"
}
output "aws_lb_listener_rule_listener_priority" {
  value       = local.enable_load_balancing ? aws_lb_listener_rule.this[0].priority : ""
  description = "The priority of the listener rule"
}

#Pipeline
output "aws_code_commit_repository_id" {
  value       = var.enable_pipeline ? aws_codecommit_repository.this[0].repository_id : ""
  description = "The ID of the CodeCommit repository"
}
output "aws_code_commit_repository_name" {
  value       = var.enable_pipeline ? aws_codecommit_repository.this[0].repository_name : ""
  description = "The name of the CodeCommit repository"
}
output "aws_code_commit_repository_url" {
  value       = var.enable_pipeline ? aws_codecommit_repository.this[0].clone_url_http : ""
  description = "The URL to use for cloning the repository over HTTPS"
}
output "aws_code_pipeline_id" {
  value       = var.enable_pipeline ? aws_codepipeline.this[0].id : ""
  description = "The ID of the CodePipeline"
}
output "aws_code_pipeline_name" {
  value       = var.enable_pipeline ? aws_codepipeline.this[0].name : ""
  description = "The name of the CodePipeline"
}
output "aws_code_pipeline_arn" {
  value       = var.enable_pipeline ? aws_codepipeline.this[0].arn : ""
  description = "The ARN of the CodePipeline"
}


#CodeDeploy
output "aws_code_deploy_application_name" {
  value       = var.enable_pipeline ? aws_codedeploy_app.this[0].name : ""
  description = "The name of the CodeDeploy application"
}
output "aws_code_deploy_deployment_group_id" {
  value       = var.enable_pipeline ? aws_codedeploy_deployment_group.this[0].id : ""
  description = "The ID of the CodeDeploy deployment group"
}
output "aws_code_deploy_deployment_group_arn" {
  value       = var.enable_pipeline ? aws_codedeploy_deployment_group.this[0].arn : ""
  description = "The ARN of the CodeDeploy deployment group"
}
output "aws_code_deploy_service_role_arn" {
  value       = var.enable_pipeline ? aws_iam_role.code_deploy[0].arn : ""
  description = "The ARN of the CodeDeploy service role"
}
output "aws_code_deploy_service_role_name" {
  value       = var.enable_pipeline ? aws_iam_role.code_deploy[0].name : ""
  description = "The name of the CodeDeploy service role"
}

#EventBridge
output "aws_cloudwatch_event_rule_ecr_id" {
  value       = var.enable_pipeline ? aws_cloudwatch_event_rule.ecr[0].id : ""
  description = "The ID of the CloudWatch event rule"
}
output "aws_cloudwatch_event_rule_ecr_arn" {
  value       = var.enable_pipeline ? aws_cloudwatch_event_rule.ecr[0].arn : ""
  description = "The ARN of the CloudWatch event rule"
}
output "aws_cloudwatch_event_rule_ecr_name" {
  value       = var.enable_pipeline ? aws_cloudwatch_event_rule.ecr[0].name : ""
  description = "The name of the CloudWatch event rule"
}
output "aws_cloudwatch_event_target_ecr_id" {
  value       = var.enable_pipeline ? aws_cloudwatch_event_target.ecr[0].id : ""
  description = "The ID of the CloudWatch event target"
}
output "aws_cloudwatch_event_target_ecr_arn" {
  value       = var.enable_pipeline ? aws_cloudwatch_event_target.ecr[0].arn : ""
  description = "The ARN of the CloudWatch event target"
}
output "aws_cloudwatch_event_rule_codecommit_id" {
  value       = var.enable_pipeline ? aws_cloudwatch_event_rule.codecommit[0].id : ""
  description = "The ID of the CloudWatch event rule"
}
output "aws_cloudwatch_event_rule_codecommit_arn" {
  value       = var.enable_pipeline ? aws_cloudwatch_event_rule.codecommit[0].arn : ""
  description = "The ARN of the CloudWatch event rule"
}
output "aws_cloudwatch_event_rule_codecommit_name" {
  value       = var.enable_pipeline ? aws_cloudwatch_event_rule.codecommit[0].name : ""
  description = "The name of the CloudWatch event rule"
}
output "aws_cloudwatch_event_target_codecommit_id" {
  value       = var.enable_pipeline ? aws_cloudwatch_event_target.codecommit[0].id : ""
  description = "The ID of the CloudWatch event target"
}
output "aws_cloudwatch_event_target_codecommit_arn" {
  value       = var.enable_pipeline ? aws_cloudwatch_event_target.codecommit[0].arn : ""
  description = "The ARN of the CloudWatch event target"
}

#CloudWatch
output "aws_cloudwatch_metric_alarm_target_group_green_5xx_arn" {
  value       = var.enable_pipeline ? aws_cloudwatch_metric_alarm.target-group-green-5xx[0].arn : ""
  description = "The ARN of the 5xx HTTP response CloudWatch metric alarm for the green target group"
}
output "aws_cloudwatch_metric_alarm_target_group_green_5xx_id" {
  value       = var.enable_pipeline ? aws_cloudwatch_metric_alarm.target-group-green-5xx[0].id : ""
  description = "The ID of the 5xx HTTP response CloudWatch metric alarm for the green target group"
}
output "aws_cloudwatch_metric_alarm_target_group_green_4xx_arn" {
  value       = var.enable_pipeline ? aws_cloudwatch_metric_alarm.target-group-green-4xx[0].arn : ""
  description = "The ARN of the 4xx HTTP response CloudWatch metric alarm for the green target group"
}
output "aws_cloudwatch_metric_alarm_target_group_green_4xx_id" {
  value       = var.enable_pipeline ? aws_cloudwatch_metric_alarm.target-group-green-4xx[0].id : ""
  description = "The ID of the 4xx HTTP response CloudWatch metric alarm for the green target group"
}
output "aws_cloudwatch_metric_alarm_task_failed_health_check_arn" {
  value       = var.enable_pipeline ? aws_cloudwatch_metric_alarm.task-failed-health-check[0].arn : ""
  description = "The ARN of the failed health check CloudWatch metric alarm for the ECS service task health check failure"
}
output "aws_cloudwatch_metric_alarm_task_failed_health_check_id" {
  value       = var.enable_pipeline ? aws_cloudwatch_metric_alarm.task-failed-health-check[0].id : ""
  description = "The ID of the failed health check CloudWatch metric alarm for the ECS service task health check failure"
}

#CodeStar
output "aws_codestarnotifications_notification_rule_codecommit_arn" {
  value       = var.enable_pipeline ? aws_codestarnotifications_notification_rule.code_commit[0].arn : ""
  description = "The ARN of the CodeStar notification rule for code commit actions"
}
output "aws_codestarnotifications_notification_rule_codecommit_id" {
  value       = var.enable_pipeline ? aws_codestarnotifications_notification_rule.code_commit[0].id : ""
  description = "The ID of the CodeStar notification rule for code commit actions"
}
output "aws_codestarnotifications_notification_rule_codecommit_name" {
  value       = var.enable_pipeline ? aws_codestarnotifications_notification_rule.code_commit[0].name : ""
  description = "The name of the CodeStar notification rule for code commit actions"
}
output "aws_codestarnotifications_notification_rule_code_pipeline_arn" {
  value       = var.enable_pipeline ? aws_codestarnotifications_notification_rule.code_pipeline[0].arn : ""
  description = "The ARN of the CodeStar notification rule for code pipeline actions"
}
output "aws_codestarnotifications_notification_rule_code_pipeline_id" {
  value       = var.enable_pipeline ? aws_codestarnotifications_notification_rule.code_pipeline[0].id : ""
  description = "The ID of the CodeStar notification rule for code pipeline actions"
}
output "aws_codestarnotifications_notification_rule_code_pipeline_name" {
  value       = var.enable_pipeline ? aws_codestarnotifications_notification_rule.code_pipeline[0].name : ""
  description = "The name of the CodeStar notification rule for code pipeline actions"
}

#S3
output "aws_s3_bucket_artifacts_id" {
  value       = var.enable_pipeline ? module.pipeline_artifacts_bucket.s3_bucket_id : ""
  description = "The ARN of the S3 bucket for artifacts"
}
output "aws_s3_bucket_artifacts_arn" {
  value       = var.enable_pipeline ? module.pipeline_artifacts_bucket.s3_bucket_arn : ""
  description = "The ARN of the S3 bucket for artifacts"
}
output "aws_s3_bucket_artifacts_region" {
  value       = var.enable_pipeline ? module.pipeline_artifacts_bucket.s3_bucket_region : ""
  description = "The region of the S3 bucket for artifacts"
}

#SNS
output "aws_sns_topic_deploy_pipeline_arn" {
  value       = var.enable_pipeline ? aws_sns_topic.this[0].arn : ""
  description = "The ARN of the SNS topic for codestar alerts"
}
output "aws_sns_topic_deploy_pipeline_id" {
  value       = var.enable_pipeline ? aws_sns_topic.this[0].id : ""
  description = "The ID of the SNS topic for codestar alerts"
}
output "aws_sns_topic_deploy_pipeline_name" {
  value       = var.enable_pipeline ? aws_sns_topic.this[0].name : ""
  description = "The name of the SNS topic for codestar alerts"
}
output "aws_sns_topic_subscription_deploy_pipeline_arn" {
  value       = var.enable_pipeline && var.sns_topic_subscription_email != null ? aws_sns_topic_subscription.this[0].arn : ""
  description = "The ARN of the SNS topic subscription for codestar alerts"
}
output "aws_sns_topic_subscription_deploy_pipeline_id" {
  value       = var.enable_pipeline && var.sns_topic_subscription_email != null ? aws_sns_topic_subscription.this[0].id : ""
  description = "The ID of the SNS topic subscription for codestar alerts"
}
output "aws_sns_topic_subscription_deploy_pipeline_endpoint" {
  value       = var.enable_pipeline && var.sns_topic_subscription_email != null ? aws_sns_topic_subscription.this[0].endpoint : ""
  description = "The endpoint of the SNS topic subscription for codestar alerts"
}
output "aws_sns_topic_subscription_deploy_pipeline_protocol" {
  value       = var.enable_pipeline && var.sns_topic_subscription_email != null ? aws_sns_topic_subscription.this[0].protocol : ""
  description = "The protocol of the SNS topic subscription for codestar alerts"
}

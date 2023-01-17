module "cpu_autoscaling" {
  source = "./modules/autoscaling/cpu_step"

  create = var.enable_autoscaling && !var.autoscaling_configuration.enable_target_tracking

  application_name          = var.application_name
  ecs_cluster_name          = var.cluster_name
  ecs_service_name          = var.enable_pipeline ? aws_ecs_service.pipeline_enabled[0].name : aws_ecs_service.pipeline_disabled[0].name
  scale_target_min_capacity = var.desired_count
  max_cpu_threshold         = try(var.autoscaling_configuration.max_cpu_threshold, 65)
  max_cpu_period            = try(var.autoscaling_configuration.max_cpu_period, 60)
  max_cpu_evaluation_period = try(var.autoscaling_configuration.max_cpu_evaluation_period, 3)
  min_cpu_threshold         = try(var.autoscaling_configuration.min_cpu_threshold, 15)
  min_cpu_period            = try(var.autoscaling_configuration.min_cpu_period, 60)
  min_cpu_evaluation_period = try(var.autoscaling_configuration.min_cpu_evaluation_period, 3)
  scale_target_max_capacity = try(var.autoscaling_configuration.scale_target_max_capacity, 5)
}

module "request_count_target_tracking_autoscaling" {
  source = "./modules/autoscaling/request_count_target_tracking"

  create = var.enable_autoscaling && var.autoscaling_configuration.enable_target_tracking

  application_name         = var.application_name
  ecs_cluster_name         = var.cluster_name
  ecs_service_name         = var.enable_pipeline ? aws_ecs_service.pipeline_enabled[0].name : aws_ecs_service.pipeline_disabled[0].name
  code_pipeline_sns_arn    = try(aws_sns_topic.this[0].arn, null)
  code_deploy_iam_role_arn = try(aws_iam_role.code_deploy[0].arn, "")
  load_balancer_name       = var.load_balancer_name

  scale_target_min_capacity   = var.desired_count
  scale_target_max_capacity   = try(var.autoscaling_configuration.scale_target_max_capacity, 5)
  autoscale_target_value      = try(var.autoscaling_configuration.autoscale_target_value, 150)
  log_group_retention_in_days = try(var.autoscaling_configuration.log_group_retention_in_days, 30)
}

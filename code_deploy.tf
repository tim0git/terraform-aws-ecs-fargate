resource "aws_codedeploy_app" "this" {
  count            = var.enable_pipeline ? 1 : 0
  compute_platform = "ECS"
  name             = var.application_name
}

resource "aws_codedeploy_deployment_group" "this" {
  count                  = var.enable_pipeline ? 1 : 0
  app_name               = aws_codedeploy_app.this[0].name
  deployment_config_name = var.deploy_config_name
  deployment_group_name  = var.application_name
  service_role_arn       = aws_iam_role.code_deploy[0].arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 2
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.cluster_name
    service_name = aws_ecs_service.pipeline_enabled[0].name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [data.aws_lb_listener.this[0].arn]
      }

      target_group {
        name = aws_lb_target_group.blue[0].name
      }

      target_group {
        name = aws_lb_target_group.green[0].name
      }
    }
  }

  alarm_configuration {
    alarms = [
      aws_cloudwatch_metric_alarm.target-group-green-5xx[0].arn,
      aws_cloudwatch_metric_alarm.target-group-green-4xx[0].arn,
      aws_cloudwatch_metric_alarm.target-group-blue-5xx[0].arn,
      aws_cloudwatch_metric_alarm.target-group-blue-4xx[0].arn,
      aws_cloudwatch_metric_alarm.task-failed-health-check[0].arn,
    ]
    enabled                   = true
    ignore_poll_alarm_failure = false
  }
}


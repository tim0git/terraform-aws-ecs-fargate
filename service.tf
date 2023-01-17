locals {
  enable_load_balancing = var.load_balancer_name != null ? true : false
}

resource "aws_ecs_service" "pipeline_disabled" {
  count           = var.enable_pipeline ? 0 : 1
  name            = "${var.application_name}-"
  cluster         = data.aws_ecs_cluster.this.arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = data.aws_security_groups.this.ids
    assign_public_ip = false
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }
  }

  dynamic "load_balancer" {
    for_each = local.enable_load_balancing ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.blue[0].id
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  depends_on = [
    aws_ecs_task_definition.this,
    aws_iam_role.execution,
    aws_iam_role.task,
    aws_iam_policy_attachment.execution,
    aws_iam_policy_attachment.task,
    aws_iam_policy.execution,
    aws_iam_policy.task,
  ]

  tags = var.tags
}

resource "aws_ecs_service" "pipeline_enabled" {
  count           = var.enable_pipeline ? 1 : 0
  name            = var.application_name
  cluster         = data.aws_ecs_cluster.this.arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = data.aws_security_groups.this.ids
    assign_public_ip = false
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }
  }

  dynamic "load_balancer" {
    for_each = local.enable_load_balancing ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.blue[0].id
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  depends_on = [
    aws_ecs_task_definition.this,
    aws_iam_role.execution,
    aws_iam_role.task,
    aws_iam_policy_attachment.execution,
    aws_iam_policy_attachment.task,
    aws_iam_policy.execution,
    aws_iam_policy.task,
  ]


  lifecycle {
    ignore_changes = [
      task_definition,
      capacity_provider_strategy,
      load_balancer,
    ]
  }

  tags = var.tags
}

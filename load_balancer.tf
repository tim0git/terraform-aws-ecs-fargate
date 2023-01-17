locals {
  create_pipeline_load_balancer_resources = var.enable_pipeline && var.load_balancer_name != null
}

resource "aws_lb_target_group" "blue" {
  count       = local.enable_load_balancing ? 1 : 0
  name        = local.create_pipeline_load_balancer_resources ? "${var.application_name}-blu" : var.application_name
  port        = local.container_port
  protocol    = var.target_group_protocol
  target_type = "ip"
  vpc_id      = data.aws_vpc.this.id

  deregistration_delay = var.target_group_deregistration_delay

  health_check {
    path                = try(var.target_group_health_check.path, "/")
    port                = try(var.target_group_health_check.port, "traffic-port")
    protocol            = try(var.target_group_health_check.protocol, "HTTP")
    healthy_threshold   = try(var.target_group_health_check.healthy_threshold_count, 2)
    unhealthy_threshold = try(var.target_group_health_check.unhealthy_threshold_count, 2)
    interval            = try(var.target_group_health_check.interval_seconds, 30)
    timeout             = try(var.target_group_health_check.timeout_seconds, 5)
  }

  stickiness {
    type            = try(var.target_group_stickiness.type, "lb_cookie")
    cookie_duration = try(var.target_group_stickiness.cookie_duration, 86400)
    enabled         = try(var.target_group_stickiness.enabled, false)
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_lb_target_group" "green" {
  count       = local.create_pipeline_load_balancer_resources ? 1 : 0
  name        = "${var.application_name}-grn"
  port        = local.container_port
  protocol    = var.target_group_protocol
  target_type = "ip"
  vpc_id      = data.aws_vpc.this.id

  deregistration_delay = var.target_group_deregistration_delay

  health_check {
    path                = try(var.target_group_health_check.path, "/")
    port                = try(var.target_group_health_check.port, "traffic-port")
    protocol            = try(var.target_group_health_check.protocol, "HTTP")
    healthy_threshold   = try(var.target_group_health_check.healthy_threshold_count, 2)
    unhealthy_threshold = try(var.target_group_health_check.unhealthy_threshold_count, 2)
    interval            = try(var.target_group_health_check.interval_seconds, 30)
    timeout             = try(var.target_group_health_check.timeout_seconds, 5)
  }

  stickiness {
    type            = try(var.target_group_stickiness.type, "lb_cookie")
    cookie_duration = try(var.target_group_stickiness.cookie_duration, 86400)
    enabled         = try(var.target_group_stickiness.enabled, false)
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_lb_listener_rule" "this" {
  count        = local.enable_load_balancing || local.create_pipeline_load_balancer_resources ? 1 : 0
  listener_arn = data.aws_lb_listener.this.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue[0].id
  }

  dynamic "condition" {
    for_each = var.listener_rule_conditions.path_pattern
    content {
      path_pattern {
        values = var.listener_rule_conditions.path_pattern
      }
    }
  }

  dynamic "condition" {
    for_each = var.listener_rule_conditions.host_header
    content {
      host_header {
        values = var.listener_rule_conditions.host_header
      }
    }
  }

  lifecycle {
    ignore_changes = [
      action
    ]
  }
}

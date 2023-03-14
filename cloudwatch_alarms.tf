resource "aws_cloudwatch_metric_alarm" "target-group-green-5xx" {
  count               = var.enable_pipeline ? 1 : 0
  alarm_name          = "${var.application_name}-target-group-green-http-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "SampleCount"
  threshold           = 3

  dimensions = {
    LoadBalancer = data.aws_lb.this[0].id
    TargetGroup  = aws_lb_target_group.green[0].id
  }

  alarm_description  = "Alert when the number of 5xx errors exceeds 3 target group green"
  alarm_actions      = [aws_sns_topic.this[0].arn]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "target-group-blue-5xx" {
  count               = var.enable_pipeline ? 1 : 0
  alarm_name          = "${var.application_name}-target-group-blue-http-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "SampleCount"
  threshold           = 3

  dimensions = {
    LoadBalancer = data.aws_lb.this[0].id
    TargetGroup  = aws_lb_target_group.blue[0].id
  }

  alarm_description  = "Alert when the number of 5xx errors exceeds 3 target group blue"
  alarm_actions      = [aws_sns_topic.this[0].arn]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "target-group-green-4xx" {
  count               = var.enable_pipeline ? 1 : 0
  alarm_name          = "${var.application_name}-target-group-green-http-4xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "SampleCount"
  threshold           = 3

  dimensions = {
    LoadBalancer = data.aws_lb.this[0].id
    TargetGroup  = aws_lb_target_group.green[0].id
  }

  alarm_description  = "Alert when the number of 4xx errors exceeds 3 target group green"
  alarm_actions      = [aws_sns_topic.this[0].arn]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "target-group-blue-4xx" {
  count               = var.enable_pipeline ? 1 : 0
  alarm_name          = "${var.application_name}-target-group-blue-http-4xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "SampleCount"
  threshold           = 3

  dimensions = {
    LoadBalancer = data.aws_lb.this[0].id
    TargetGroup  = aws_lb_target_group.blue[0].id
  }

  alarm_description  = "Alert when the number of 4xx errors exceeds 3 target group blue"
  alarm_actions      = [aws_sns_topic.this[0].arn]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "task-failed-health-check" {
  count               = var.enable_pipeline ? 1 : 0
  alarm_name          = "${var.application_name}-task-failed-health-check"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "TriggeredRules"
  namespace           = "AWS/Events"
  period              = 60
  statistic           = "SampleCount"
  threshold           = 2

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.task-failed-health-check[0].name
  }

  alarm_description  = "Alert when event bridge rule is triggered by a task failing a health check"
  alarm_actions      = [aws_sns_topic.this[0].arn]
  treat_missing_data = "notBreaching"
}

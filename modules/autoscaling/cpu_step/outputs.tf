output "scale_down_policy_arn" {
  value       = try(aws_appautoscaling_policy.scale_down_policy[0].arn, "")
  description = "ARN of the scale down policy"
}

output "scale_up_policy_arn" {
  value       = try(aws_appautoscaling_policy.scale_up_policy[0].arn, "")
  description = "ARN of the scale up policy"
}

output "metric_alarm_cpu_high_arn" {
  value       = try(aws_cloudwatch_metric_alarm.cpu_high[0].arn, "")
  description = "ARN of the CPU high metric alarm"
}

output "metric_alarm_cpu_low_arn" {
  value       = try(aws_cloudwatch_metric_alarm.cpu_low[0].arn, "")
  description = "ARN of the CPU low metric alarm"
}

output "scale_target_id" {
  value       = try(aws_appautoscaling_target.scale_target[0].id, "")
  description = "ID of the scale target"
}



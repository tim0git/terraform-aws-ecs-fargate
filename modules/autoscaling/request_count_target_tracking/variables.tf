#Required Variables
variable "create" {
  type        = bool
  description = "Create or destroy the resources"
  default     = true
}

##Lookup Variables
variable "application_name" {
  type        = string
  description = "Name of the application"
}
variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}
variable "ecs_service_name" {
  type        = string
  description = "Name of the ECS service"
}
variable "load_balancer_name" {
  type        = string
  description = "Name of the load balancer"
}
variable "code_pipeline_sns_arn" {
  type        = string
  description = "ARN of the SNS topic for CodePipeline"
}
variable "code_deploy_iam_role_arn" {
  type        = string
  description = "ARN of the IAM role for CodeDeploy"
}

#Default Variables
variable "autoscale_target_value" {
  type        = string
  description = "Target value for the autoscaling policy (Target group request count)"
  default     = "150"
}
variable "scale_target_max_capacity" {
  type        = number
  description = "The max capacity of the scalable target"
  default     = 5
}
variable "scale_target_min_capacity" {
  type        = number
  description = "The min capacity of the scalable target"
  default     = 1
}
variable "log_group_retention_in_days" {
  type        = number
  description = "The number of days to retain log events"
  default     = 30
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}

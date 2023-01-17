#Required Variables
variable "create" {
  description = "Create or destroy the resources"
  default     = true
}

##Lookup Variables
variable "application_name" {
  description = "Name of the application"
}
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
}
variable "ecs_service_name" {
  description = "Name of the ECS service"
}

#Default Variables
variable "max_cpu_threshold" {
  description = "Threshold for max CPU usage"
  default     = "65"
  type        = string
}
variable "min_cpu_threshold" {
  description = "Threshold for min CPU usage"
  default     = "15"
  type        = string
}
variable "max_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for max cpu metric alarm"
  default     = "3"
  type        = string
}
variable "min_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for min cpu metric alarm"
  default     = "3"
  type        = string
}
variable "max_cpu_period" {
  description = "The period in seconds over which the specified statistic is applied for max cpu metric alarm"
  default     = "60"
  type        = string
}
variable "min_cpu_period" {
  description = "The period in seconds over which the specified statistic is applied for min cpu metric alarm"
  default     = "60"
  type        = string
}
variable "scale_target_max_capacity" {
  description = "The max capacity of the scalable target"
  default     = 5
  type        = number
}
variable "scale_target_min_capacity" {
  description = "The min capacity of the scalable target"
  default     = 1
  type        = number
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}

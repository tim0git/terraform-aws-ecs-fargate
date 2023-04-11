#Required Variables
variable "application_name" {
  type        = string
  description = "Name of the application"

  validation {
    condition     = length(var.application_name) <= 28
    error_message = format("The application_name variable must be less than or equal to 26 characters current length is %s", length(var.application_name))
  }
}
variable "container_definition" {
  type        = any
  description = "Container definitions for the application"
}


##Lookup Variables
variable "cluster_name" {
  type        = string
  description = "Name of ECS Cluster to deploy to"
}
variable "security_groups_names" {
  type        = list(string)
  description = "Tags to use to lookup security groups"
}
variable "subnet_names" {
  type        = list(string)
  description = "Tags to use to lookup subnets"
}
variable "load_balancer_name" {
  type        = string
  description = "Name of the load balancer to attach to"
  default     = null
}
variable "vpc_name" {
  type        = string
  description = "Name of the VPC to deploy to"
}

#Default Variables
variable "desired_count" {
  type        = number
  description = "Number of tasks to run"
  default     = 1
}
variable "capacity_provider_strategy" {
  type        = list(object({ base = number, capacity_provider = string, weight = number }))
  description = "List of capacity providers to use, default fargate spot 100%"
  default = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 0
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
      base              = 0
    }
  ]
}
variable "runtime_platform" {
  type = object({ cpu_architecture = string, operating_system_family = string })
  default = {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  description = "Runtime platform for the task, default linux x86_64"
}
variable "load_balancer_listener_port" {
  type        = number
  description = "Port to attach the load balancer to"
  default     = 443
}
variable "listener_rule_conditions" {
  type        = object({ host_header = list(string), path_pattern = list(string) })
  description = "List of conditions to use for the listener rule"
  default = {
    path_pattern = ["/*"]
    host_header  = []
  }
}
variable "target_group_protocol" {
  type        = string
  description = "Protocol to use for the target group"
  default     = "HTTP"
}
variable "target_group_stickiness" {
  type        = any
  description = "Stickiness settings for the target group"
  default = {
    enabled         = false
    type            = "lb_cookie"
    cookie_duration = 3600
  }
}
variable "target_group_health_check" {
  type        = any
  description = "Health check settings for the target group"
  default = {
    path                      = "/"
    port                      = "traffic-port"
    protocol                  = "HTTP"
    healthy_threshold_count   = 2
    unhealthy_threshold_count = 2
    interval_seconds          = 30
    timeout_seconds           = 5
  }
}
variable "target_group_deregistration_delay" {
  type        = number
  description = "Deregistration delay for the target group"
  default     = 120
}
variable "enable_autoscaling" {
  type        = bool
  description = "Enable autoscaling"
  default     = false
}
variable "autoscaling_configuration" {
  type        = any
  description = "Autoscaling parameters for both target tracking and cpu step scaling policies"
  default = {
    max_cpu_threshold         = 65
    max_cpu_period            = 60
    max_cpu_evaluation_period = 3
    min_cpu_threshold         = 15
    min_cpu_period            = 60
    min_cpu_evaluation_period = 3
    scale_target_max_capacity = 5
    autoscale_target_value    = 150
    enable_target_tracking    = false
  }
}
variable "enable_pipeline" {
  type        = bool
  description = "Enable code pipeline"
  default     = false
}
variable "s3_access_logs_bucket_name" {
  type        = string
  description = "S3 bucket to store access logs"
  default     = null
}
variable "deploy_config_name" {
  type        = string
  description = "The name of the deployment configuration. Options are: CodeDeployDefault.ECSLinear10PercentEvery1Minutes, CodeDeployDefault.ECSLinear10PercentEvery3Minutes, CodeDeployDefault.ECSAllAtOnce, CodeDeployDefault.ECSCanary10Percent5Minutes, CodeDeployDefault.ECSCanary10Percent15Minutes"
  default     = "CodeDeployDefault.ECSAllAtOnce"
}
variable "ecs_task_custom_policy_arns" {
  type        = list(string)
  description = "Custom policy to attach to the task role"
  default     = []
}
variable "sns_topic_subscription_email" {
  type        = string
  description = "Email to subscribe to the pipeline notifications"
  default     = null
}
variable "volume" {
  type = object({
    efs_volume_configuration = object({
      authorization_config = object({
        access_point_id = string,
      iam = string }),
      file_system_id     = string,
      root_directory     = string,
      transit_encryption = string,
    transit_encryption_port = number }),
    name = string
  })
  description = "Volume to attach to the task (Fargate only supports EFS)"
  default = {
    name = "disabled"
    efs_volume_configuration = {
      file_system_id          = "null"
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config = {
        access_point_id = "null"
        iam             = "DISABLED"
      }
    }
  }
}
variable "custom_aws_profile" {
  type        = string
  description = "AWS profile to use for task definition push to code commit"
  default     = "default"
}
variable "aws_firelens_image_uri" {
  type        = string
  description = "Image URI for the firelens container"
  default     = "public.ecr.aws/aws-observability/aws-for-fluent-bit:stable"
}
variable "new_relic_firelens_image_uri" {
  type        = object({ ap-northeast-1 = string, ap-northeast-2 = string, ap-northeast-3 = string, ap-south-1 = string, ap-southeast-1 = string, ap-southeast-2 = string, ca-central-1 = string, eu-central-1 = string, eu-north-1 = string, eu-west-1 = string, eu-west-2 = string, eu-west-3 = string, sa-east-1 = string, us-east-1 = string, us-east-2 = string, us-west-1 = string, us-west-2 = string })
  description = "Image URI for the firelens container"
  default = {
    "ap-northeast-1" : "533243300146.dkr.ecr.ap-northeast-1.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "ap-northeast-2" : "533243300146.dkr.ecr.ap-northeast-2.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "ap-northeast-3" : "533243300146.dkr.ecr.ap-northeast-3.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "ap-south-1" : "533243300146.dkr.ecr.ap-south-1.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "ap-southeast-1" : "533243300146.dkr.ecr.ap-southeast-1.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "ap-southeast-2" : "533243300146.dkr.ecr.ap-southeast-2.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "ca-central-1" : "533243300146.dkr.ecr.ca-central-1.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "eu-central-1" : "533243300146.dkr.ecr.eu-central-1.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "eu-north-1" : "533243300146.dkr.ecr.eu-north-1.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "eu-west-1" : "533243300146.dkr.ecr.eu-west-1.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "eu-west-2" : "533243300146.dkr.ecr.eu-west-2.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "eu-west-3" : "533243300146.dkr.ecr.eu-west-3.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "sa-east-1" : "533243300146.dkr.ecr.sa-east-1.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "us-east-1" : "533243300146.dkr.ecr.us-east-1.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "us-east-2" : "533243300146.dkr.ecr.us-east-2.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "us-west-1" : "533243300146.dkr.ecr.us-west-1.amazonaws.com/newrelic/logging-firelens-fluentbit"
    "us-west-2" : "533243300146.dkr.ecr.us-west-2.amazonaws.com/newrelic/logging-firelens-fluentbit"
  }
}
variable "reverse_proxy_configuration" {
  type = object({
    image_uri     = string,
    listener_port = number,
    proxy_port    = number,
  })
  description = "Reverse proxy configuration"
  default = {
    image_uri     = null,
    listener_port = 8443,
    proxy_port    = 3000
  }
}
variable "log_group_retention_in_days" {
  type        = number
  description = "Log group retention in days"
  default     = 30
}
variable "task_definition_memory_cpu_configuration" {
  type = object({
    cpu    = number,
    memory = number
  })
  description = "Task definition memory and cpu configuration"
  default = {
    cpu    = 1024
    memory = 2048
  }
}
variable "side_car_resource_allocation_configuration" {
  type        = any
  description = "Side car resource allocation configuration (Values given in decimal %)"
  default = {
    reverse_proxy = {
      cpu    = 0.125
      memory = 0.0625
    }
    firelens = {
      cpu    = 0.125
      memory = 0.0625
    }
    new_relic_infra_agent = {
      cpu    = 0.125
      memory = 0.125
    },
    app_config_agent = {
      cpu    = 0.125
      memory = 0.0625
    }
  }
}
variable "readonly_root_file_system" {
  type        = bool
  default     = true
  description = "Whether to enable readonly root file system for the task definition"
}
variable "enable_app_config" {
  type        = bool
  description = "Enable app config side car see https://docs.aws.amazon.com/appconfig/latest/userguide/appconfig-integrations-ecs.html"
  default     = false
}
variable "app_config_image_uri" {
  type        = string
  description = "Image URI for the app config container see https://gallery.ecr.aws/aws-appconfig/aws-appconfig-agent"
  default     = "public.ecr.aws/aws-appconfig/aws-appconfig-agent:2.x"
}
variable "app_config_environmental_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Environmental variables for the app config container see https://docs.aws.amazon.com/appconfig/latest/userguide/appconfig-integrations-ecs.html"
  default     = []
}
variable "tags" {
  type        = map(string)
  description = "Default tags to apply to all resources"
}

locals {
  default_application_health_check = {
    "command" : [
      "CMD-SHELL",
      "echo '{\"health\": \"check\"}' | nc localhost:${var.container_definition.portMappings[0].containerPort} || exit 1"
    ],
    "interval" : 30,
    "retries" : 3,
    "startPeriod" : 10,
    "timeout" : 5
  }
  default_firelense_log_configuration_options = {
    "Name" : "cloudwatch",
    "region" : data.aws_region.current.name,
    "log_group_name" : "ecs/${var.application_name}",
    "auto_create_group" : "true",
    "log_stream_prefix" : var.application_name
  }
  use_ecs_awslog_driver                    = try(var.container_definition.logConfiguration.logDriver != "awslogs", true)
  use_new_relic_firelens_image             = try(var.container_definition.logConfiguration.options["Name"] == "newrelic", false)
  use_reverse_proxy_side_car               = var.reverse_proxy_configuration.image_uri != null
  depends_on_reverse_proxy                 = local.use_reverse_proxy_side_car ? [{ containerName : "${var.application_name}-reverse-proxy", condition : "START" }] : []
  depends_on_firelens                      = local.use_ecs_awslog_driver ? [{ containerName : "${var.application_name}-firelens-log-agent", condition : "START" }] : []
  depends_on_newrelic_infrastructure_agent = local.use_new_relic_firelens_image ? [{ containerName : "${var.application_name}-newrelic-infra-agent", condition : "START" }] : []
  depends_on_app_config_agent              = var.enable_app_config ? [{ containerName : "${var.application_name}-app-config-agent", condition : "START" }] : []
  depends_on_xray_daemon                   = var.enable_xray ? [{ containerName : "${var.application_name}-xray-daemon", condition : "START" }] : []

  side_cars = concat(
    local.firelense_container_definition,
    local.reverse_proxy_container_definition,
    local.new_relic_ecs_infrastructure_monitor_container_definition,
    local.app_config_agent_container_definition,
    local.xray_daemon_container_definition
  )
}

locals {
  reverse_proxy_container_definition = local.use_reverse_proxy_side_car ? [{
    name : "${var.application_name}-reverse-proxy",
    image  = var.reverse_proxy_configuration.image_uri,
    cpu    = local.reverse_proxy_cpu_allocation,
    memory = local.reverse_proxy_memory_allocation,
    essential : true,
    portMappings = [
      {
        "containerPort" : var.reverse_proxy_configuration.listener_port,
        "hostPort" : var.reverse_proxy_configuration.listener_port,
        "protocol" : "tcp"
      }
    ],
    logConfiguration : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : "ecs/${var.application_name}",
        "awslogs-region" : data.aws_region.current.name,
        "awslogs-create-group" : "true",
        "awslogs-stream-prefix" : "reverse-proxy"
      }
    }
    environment = [
      {
        "name" : "NGINX_LISTEN_PORT",
        "value" : tostring(var.reverse_proxy_configuration.listener_port)
      },
      {
        "name" : "NGINX_PROXY_PORT",
        "value" : tostring(var.reverse_proxy_configuration.proxy_port)
      }
    ]
    mountPoints = [],
    volumesFrom = [],
  }] : []

  firelense_container_definition = local.use_ecs_awslog_driver ? [{
    name : "${var.application_name}-firelens-log-agent",
    image  = local.use_new_relic_firelens_image ? var.new_relic_firelens_image_uri[data.aws_region.current.name] : var.aws_firelens_image_uri,
    cpu    = local.firelense_log_agent_cpu_allocation,
    memory = local.firelense_log_agent_memory_allocation,
    essential : true,
    firelensConfiguration : {
      "type" : "fluentbit"
    },
    logConfiguration : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : "ecs/${var.application_name}",
        "awslogs-region" : data.aws_region.current.name,
        "awslogs-create-group" : "true",
        "awslogs-stream-prefix" : "firelens"
      }
    },
    environment            = [],
    readonlyRootFilesystem = var.readonly_root_file_system
    mountPoints            = [],
    portMappings           = [],
    volumesFrom            = [],
    user                   = "0"
    healthCheck = {
      "command" : [
        "CMD-SHELL",
        "echo '{\"health\": \"check\"}' | nc 127.0.0.1 8877 || exit 1"
      ],
      "interval" : 30,
      "retries" : 3,
      "startPeriod" : 10,
      "timeout" : 5
    },
  }] : []

  application_container_definition = [{
    name                   = var.application_name
    image                  = var.container_definition.image
    cpu                    = try(var.container_definition.cpu, local.calculated_application_cpu_allocation)
    memory                 = try(var.container_definition.memory, local.calculated_application_memory_allocation)
    essential              = true
    portMappings           = var.container_definition.portMappings
    environment            = try(var.container_definition.environment, [])
    environmentFiles       = try(var.container_definition.environmentFiles, [])
    secrets                = try(var.container_definition.secrets, null)
    volumesFrom            = try(var.container_definition.volumesFrom, [])
    readonlyRootFilesystem = try(var.container_definition.readonlyRootFilesystem, var.readonly_root_file_system)
    mountPoints            = try(var.container_definition.mountPoints, [])
    healthCheck            = try(var.container_definition.healthCheck, local.default_application_health_check)
    user                   = try(var.container_definition.user, null)
    command                = try(var.container_definition.command, null)
    entryPoint             = try(var.container_definition.entryPoint, null)
    logConfiguration = {
      "logDriver" : try(var.container_definition.logConfiguration.logDriver, "awsfirelens")
      "options" : try(var.container_definition.logConfiguration.options, local.default_firelense_log_configuration_options)
      "secretOptions" : try(var.container_definition.logConfiguration.secretOptions, [])
    },
    dependsOn = flatten(concat(
      local.depends_on_reverse_proxy,
      local.depends_on_firelens,
      local.depends_on_newrelic_infrastructure_agent,
      local.depends_on_app_config_agent,
      local.depends_on_xray_daemon
    ))
  }]

  new_relic_ecs_infrastructure_monitor_container_definition = local.use_new_relic_firelens_image ? [{
    image     = "newrelic/nri-ecs:latest",
    name      = "${var.application_name}-newrelic-infra-agent",
    essential = true,
    secrets = [
      {
        "valueFrom" : var.container_definition.logConfiguration.secretOptions[0].valueFrom,
        "name" : "NRIA_LICENSE_KEY"
      }
    ],
    cpu          = local.new_relic_infrastructure_agent_cpu_allocation,
    memory       = local.new_relic_infrastructure_agent_memory_allocation,
    mountPoints  = [],
    portMappings = [],
    volumesFrom  = [],
    environment = [
      {
        "name" : "NRIA_OVERRIDE_HOST_ROOT",
        "value" : ""
      },
      {
        "name" : "NRIA_IS_FORWARD_ONLY",
        "value" : "true"
      },
      {
        "name" : "FARGATE",
        "value" : "true"
      },
      {
        "name" : "NRIA_PASSTHROUGH_ENVIRONMENT",
        "value" : "ECS_CONTAINER_METADATA_URI,ECS_CONTAINER_METADATA_URI_V4,FARGATE"
      },
      {
        "name" : "NRIA_CUSTOM_ATTRIBUTES",
        "value" : jsonencode(
          merge({ Cluster = var.cluster_name, Application = var.application_name }, var.tags)
        )
      }
    ]
  }] : []

  app_config_agent_container_definition = var.enable_app_config ? [{
    name : "${var.application_name}-app-config-agent",
    image  = var.app_config_image_uri,
    cpu    = local.app_config_agent_cpu_allocation,
    memory = local.app_config_agent_memory_allocation,
    essential : true,
    portMappings = [
      {
        "containerPort" : 2772
        "hostPort" : 2772,
        "protocol" : "tcp"
      }
    ],
    logConfiguration : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : "ecs/${var.application_name}",
        "awslogs-region" : data.aws_region.current.name,
        "awslogs-create-group" : "true",
        "awslogs-stream-prefix" : "app-config-agent"
      }
    }
    environment = concat(var.app_config_environmental_variables, [{
      name  = "ROLE_ARN",
      value = aws_iam_role.app_config_agent[0].arn
    }])
    mountPoints = [],
    volumesFrom = [],
  }] : []

  xray_daemon_container_definition = var.enable_xray ? [{
    name : "${var.application_name}-xray-daemon",
    image  = var.xray_daemon_image_uri,
    cpu    = local.xray_daemon_cpu_allocation,
    memory = local.xray_daemon_memory_allocation,
    essential : true,
    portMappings : [
      {
        "containerPort" : 2000,
        "protocol" : "udp"
      }
    ]
    logConfiguration : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : "ecs/${var.application_name}",
        "awslogs-region" : data.aws_region.current.name,
        "awslogs-create-group" : "true",
        "awslogs-stream-prefix" : "xray-daemon"
      }
    }
    environment = [],
    mountPoints = [],
    volumesFrom = [],
  }] : []
}

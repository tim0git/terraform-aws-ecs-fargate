module "service_complete" {
  source = "../../"

  application_name = "example"
  container_definition = {
    image = "12345678910.dkr.ecr.us-east-1.amazonaws.com/example-application-image:latest"
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      },
    ]
    cpu         = 256
    memory      = 512
    environment = []
    secrets     = []
    mountPoints = [
      {
        "sourceVolume" : "myEfsVolume",
        "containerPath" : "/mount/efs",
        "readOnly" : true
      }
    ]
    volumesFrom = []
    healthCheck = []
    user        = ""
    command     = []
    entryPoint  = []
  }

  ecs_task_custom_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  ]

  vpc_name              = "example-vpc"
  cluster_name          = "example-cluster"
  subnet_names          = ["example-private-us-east-1a", "example-private-us-east-1b"]
  security_groups_names = ["example-ecs-service"]

  desired_count = 2

  capacity_provider_strategy = [
    {
      capacityProvider = "FARGATE_SPOT"
      weight           = 1
      base             = 0
    },
    {
      capacityProvider = "FARGATE"
      weight           = 1
      base             = 0
    }
  ]

  runtime_platform = {
    "cpu_architecture" = "x86_64"
    "operating_system" = "LINUX"
  }

  load_balancer_name          = "example-load-balancer"
  load_balancer_listener_port = 443
  listener_rule_conditions = {
    path_pattern = ["/*"]
    host_header  = ["example.com"]
  }

  target_group_protocol = "HTTP"
  target_group_stickiness = {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }
  target_group_health_check = {
    path                      = "/api/health"
    port                      = "traffic-port"
    protocol                  = "HTTP"
    healthy_threshold_count   = 2
    unhealthy_threshold_count = 2
    interval_seconds          = 30
    timeout_seconds           = 5
  }
  target_group_deregistration_delay = 300

  enable_pipeline              = true
  s3_access_logs_bucket_name   = "example-logs"
  sns_topic_subscription_email = "example@exaple.com"
  deploy_config_name           = "CodeDeployDefault.ECSAllAtOnce"

  enable_autoscaling = true
  autoscaling_configuration = {
    autoscale_target_value    = 150 # Require if target tracking scaling policy is enabled
    enable_target_tracking    = false
    max_cpu_threshold         = 65
    max_cpu_period            = 60
    max_cpu_evaluation_period = 3
    min_cpu_threshold         = 15
    min_cpu_period            = 60
    min_cpu_evaluation_period = 3
    scale_target_max_capacity = 5 # Require if target tracking scaling policy is enabled
  }

  reverse_proxy_configuration = {
    image_uri     = "12345678910.dkr.ecr.us-east-1.amazonaws.com/example-custom-reverse-proxy-image:latest",
    listener_port = 8443,
    proxy_port    = 3000
  }

  volume = {
    name = "myEfsVolume"
    efs_volume_configuration = {
      file_system_id          = "fs-1234"
      root_directory          = "/path/to/my/data"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config = {
        access_point_id = "fsap-1234"
        iam             = "ENABLED"
      }
    }
  }

  tags = {
    Name = "example"
  }
}
module "service_with_pipeline" {
  source = "../../"

  application_name = "example"
  container_definition = {
    image = "12345678910.dkr.ecr.us-east-1.amazonaws.com/example-application-image:latest"
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      },
    ]
    cpu    = 256
    memory = 512
  }

  vpc_name              = "example-vpc"
  cluster_name          = "example-cluster"
  subnet_names          = ["example-private-us-east-1a", "example-private-us-east-1b"]
  security_groups_names = ["example-ecs-service"]
  load_balancer_name    = "example-load-balancer"

  listener_rule_conditions = {
    path_pattern = ["/*"]
    host_header  = ["example.com"]
  }
  enable_pipeline = true

  tags = {
    Name = "example"
  }
}

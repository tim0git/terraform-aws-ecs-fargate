module "service_env_vars" {
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

    environment = [      
      {
        name  = "NAME"
        value = "Amazon"
      }
    ]
    environmentFiles = [
      {
          value = "arn:aws:s3:::12345678910-bucket/default/default.env",
          type  = "s3"
      },
      {
          value = "arn:aws:s3:::12345678910-bucket/test/default.env",
          type  = "s3"
      }
    ]
  }

  cluster_name          = "example-cluster"
  subnet_names          = ["example-private-us-east-1a", "example-private-us-east-1b"]
  security_groups_names = ["example-ecs-service"]
  vpc_name              = "example-vpc"

  enable_autoscaling = false

  tags = {
    Name = "example"
  }
}


module "service_with_reverse_proxy" {
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
    cpu = 256
    memory = 512
  }

  cluster_name = "example-cluster"
  subnet_names = ["example-private-us-east-1a", "example-private-us-east-1b"]
  security_groups_names = ["example-ecs-service"]
  vpc_name = "example-vpc"

  reverse_proxy_configuration = {
    image_uri     = "12345678910.dkr.ecr.us-east-1.amazonaws.com/example-reverse-proxy-image:latest",
    listener_port = 8443,
    proxy_port    = 3000,
  }

  tags = {
    Name = "example"
  }
}

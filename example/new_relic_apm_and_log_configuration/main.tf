module "service_new_relic_log_configuration_and_apm" {
  source = "../../"

  application_name = "example"
  container_definition = {
    image = "12345678910.dkr.ecr.us-east-1.amazonaws.com/example-application-image:latest"
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }
    ]
    cpu    = 256
    memory = 512
    secrets = [
      {
        name      = "NEW_RELIC_LICENSE_KEY"
        valueFrom = "arn:aws:secretsmanager:eu-west-1:12345678910:secret:NEW_RELIC_LICENSE_KEY"
      }
    ]
    logConfiguration = {
      options = {
        Name : "newrelic"
        enable-ecs-log-metadata : "true"
        endpoint : "https://log-api.eu.newrelic.com/log/v1"
      }
      secretOptions : [{
        name : "apiKey",
        valueFrom : "arn:aws:secretsmanager:region:aws_account_id:secret:SECRET_NAME"
      }]
    }
  }

  cluster_name          = "example-cluster"
  subnet_names          = ["example-private-us-east-1a", "example-private-us-east-1b"]
  security_groups_names = ["example-ecs-service"]
  vpc_name              = "example-vpc"

  tags = {
    Name = "example"
  }
}


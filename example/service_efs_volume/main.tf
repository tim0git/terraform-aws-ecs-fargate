module "service_efs_volume" {
  source = "../../"

  application_name = "example"
  container_definition = {
    image = "amazonlinux:2"
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      },
    ]
    cpu    = 256
    memory = 512
    entryPoint = [
      "sh",
      "-c"
    ],
    command = [
      "ls -la /mount/efs"
    ],
    mountPoints = [
      {
        "sourceVolume" : "myEfsVolume",
        "containerPath" : "/mount/efs",
        "readOnly" : true
      }
    ]
  }

  cluster_name          = "example-cluster"
  subnet_names          = ["example-private-us-east-1a", "example-private-us-east-1b"]
  security_groups_names = ["example-ecs-service"]
  vpc_name              = "example-vpc"

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


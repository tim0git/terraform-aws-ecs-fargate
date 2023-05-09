resource "aws_ecs_task_definition" "this" {
  family                   = var.application_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_definition_memory_cpu_configuration.cpu
  memory                   = var.task_definition_memory_cpu_configuration.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode(
    concat(
      local.application_container_definition,
      local.side_cars
    )
  )

  runtime_platform {
    operating_system_family = var.runtime_platform.operating_system_family
    cpu_architecture        = var.runtime_platform.cpu_architecture
  }

  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value.name
      efs_volume_configuration {
        file_system_id          = volume.value.efs_volume_configuration.file_system_id
        root_directory          = volume.value.efs_volume_configuration.root_directory
        transit_encryption      = volume.value.efs_volume_configuration.transit_encryption
        transit_encryption_port = volume.value.efs_volume_configuration.transit_encryption_port
        authorization_config {
          access_point_id = volume.value.efs_volume_configuration.authorization_config.access_point_id
          iam             = volume.value.efs_volume_configuration.authorization_config.iam
        }
      }
    }
  }

  depends_on = [
    aws_iam_role.execution,
    aws_iam_role.task,
  ]
}


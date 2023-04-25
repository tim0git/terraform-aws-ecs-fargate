resource "aws_iam_role" "execution" {
  name = lower("${var.application_name}-ecs-execution-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowECSTaskToAssumeExecutionRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_policy_attachment" "execution" {
  name       = lower("${var.application_name}-ecs-execution-policy-attachment")
  roles      = [aws_iam_role.execution.name]
  policy_arn = aws_iam_policy.execution.arn
}
resource "aws_iam_policy" "execution" {
  name        = lower("${var.application_name}-ecs-execution-policy")
  description = "Policy for ${var.application_name} ECS execution role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:*:*:secret:*"
      },
      {
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:*:*:parameter/*"
      },
    ]
  })
}

resource "aws_iam_role" "task" {
  name = lower("${var.application_name}-ecs-task-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowECSTaskToAssumeTaskRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_policy_attachment" "task" {
  name       = lower("${var.application_name}-ecs-task-policy-attachment")
  roles      = [aws_iam_role.task.name]
  policy_arn = aws_iam_policy.task.arn
}
resource "aws_iam_policy" "task" {
  name        = lower("${var.application_name}-ecs-task-policy")
  description = "Policy for ${var.application_name} ECS task role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "task_custom" {
  count      = length(var.ecs_task_custom_policy_arns)
  role       = aws_iam_role.task.name
  policy_arn = var.ecs_task_custom_policy_arns[count.index]
}
resource "aws_iam_role" "code_deploy" {
  count = var.enable_pipeline ? 1 : 0
  name  = lower("${var.application_name}-code-deploy-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowCodeDeployToAssumeRole"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "code_deploy" {
  count      = var.enable_pipeline ? 1 : 0
  role       = aws_iam_role.code_deploy[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
resource "aws_iam_policy_attachment" "xray_write_access_managed" {
  count      = var.enable_xray ? 1 : 0
  name       = lower("${var.application_name}-ecs-task-policy-attachment")
  roles      = [aws_iam_role.task.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_role" "code_pipeline" {
  count = var.enable_pipeline ? 1 : 0
  name  = lower("${var.application_name}-code-pipeline-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowCodePipelineToAssumeRole"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "code_pipeline" {
  count      = var.enable_pipeline ? 1 : 0
  role       = aws_iam_role.code_pipeline[0].name
  policy_arn = aws_iam_policy.code_pipeline[0].arn
}
resource "aws_iam_policy" "code_pipeline" {
  count       = var.enable_pipeline ? 1 : 0
  name        = lower("${var.application_name}-code-pipeline-policy")
  description = "Policy for ${var.application_name} Code Pipeline role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:PassRole"
        ],
        Condition = {
          "StringEqualsIfExists" : {
            "iam:PassedToService" : [
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        },
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "s3:*",
          "sns:*",
          "rds:*",
          "sqs:*",
          "ecs:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "lambda:InvokeFunction",
          "lambda:ListFunctions"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ecr:DescribeImages"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "event_bridge" {
  count = var.enable_pipeline ? 1 : 0
  name  = lower("${var.application_name}-event-bridge-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowEventBridgeToAssumeRole"
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_policy_attachment" "event_bridge" {
  count      = var.enable_pipeline ? 1 : 0
  name       = lower("${var.application_name}-event-bridge-policy-attachment")
  roles      = [aws_iam_role.event_bridge[0].name]
  policy_arn = aws_iam_policy.event_bridge[0].arn
}
resource "aws_iam_policy" "event_bridge" {
  count       = var.enable_pipeline ? 1 : 0
  name        = lower("${var.application_name}-event-bridge-policy")
  description = "Policy for ${var.application_name} Event Bridge role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "logs:*",
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*",
      },
      {
        Action = [
          "codepipeline:CreatePipeline",
          "codepipeline:DeletePipeline",
          "codepipeline:StartPipelineExecution"
        ],
        Effect   = "Allow",
        Resource = "*",
      }
    ]
  })
}

resource "aws_iam_role" "app_config_agent" {
  count = var.enable_app_config ? 1 : 0
  name  = lower("${var.application_name}-app-config-agent-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowAppConfigAgentAssumeRole"
        Principal = {
          "AWS" : [data.aws_caller_identity.current.account_id]
        }
      }
    ]
  })
}
resource "aws_iam_policy_attachment" "app_config_agent" {
  count      = var.enable_app_config ? 1 : 0
  name       = lower("${var.application_name}-app-config-agent-policy-attachment")
  roles      = [aws_iam_role.app_config_agent[0].name]
  policy_arn = aws_iam_policy.app_config_agent[0].arn
}
resource "aws_iam_policy" "app_config_agent" {
  count       = var.enable_app_config ? 1 : 0
  name        = lower("${var.application_name}-app-config-agent-policy")
  description = "Policy for ${var.application_name} App Config Agent Role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "appconfig:StartConfigurationSession",
          "appconfig:GetLatestConfiguration",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:appconfig:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/*/configurationprofile/*",
          "arn:aws:appconfig:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/*/environment/*/configuration/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "event_bridge_scheduler" {
  count = var.enable_service_schedule ? 1 : 0
  name  = lower("${var.application_name}-event-bridge-scheduler-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowEventBridgeSchedulerToAssumeRole"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_policy_attachment" "event_bridge_scheduler" {
  count      = var.enable_service_schedule ? 1 : 0
  name       = lower("${var.application_name}-event-bridge-scheduler-policy-attachment")
  roles      = [aws_iam_role.event_bridge_scheduler[0].name]
  policy_arn = aws_iam_policy.event_bridge_scheduler[0].arn
}
resource "aws_iam_policy" "event_bridge_scheduler" {
  count       = var.enable_service_schedule ? 1 : 0
  name        = lower("${var.application_name}-event-bridge-scheduler-policy")
  description = "Policy for ${var.application_name} Event Bridge Scheduler role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ecs:UpdateService",
        Effect   = "Allow",
        Resource = local.ecs_service_id
      }
    ]
  })
}

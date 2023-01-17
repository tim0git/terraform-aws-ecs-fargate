resource "aws_iam_role" "lambda" {
  count = var.create ? 1 : 0
  name  = lower("${var.application_name}-autoscaling-lambda-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowLambdaToAssumeExecutionRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_policy_attachment" "lambda" {
  count      = var.create ? 1 : 0
  name       = lower("${var.application_name}-autoscaling-lambda-policy-attachment")
  roles      = [aws_iam_role.lambda[0].name]
  policy_arn = aws_iam_policy.lambda[0].arn
}
resource "aws_iam_policy" "lambda" {
  count       = var.create ? 1 : 0
  name        = lower("${var.application_name}-autoscaling-execution-policy")
  description = "Policy for ${var.application_name} Autoscaling Lambda execution role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : "logs:CreateLogGroup",
        "Resource" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*:*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecs:DescribeServices",
          "elasticloadbalancing:Describe*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "application-autoscaling:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}


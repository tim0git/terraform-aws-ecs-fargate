resource "aws_sns_topic" "this" {
  count = var.enable_pipeline ? 1 : 0
  name  = "${var.application_name}-deploy-pipeline"
}

data "aws_iam_policy_document" "this" {
  count = var.enable_pipeline ? 1 : 0
  statement {
    sid     = "AllowSNSPublish"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    resources = [aws_sns_topic.this[0].arn]
  }

  statement {
    sid = "AllowSNSSubscribe"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = [aws_sns_topic.this[0].arn]
  }
}

resource "aws_sns_topic_policy" "this" {
  count  = var.enable_pipeline ? 1 : 0
  arn    = aws_sns_topic.this[0].arn
  policy = data.aws_iam_policy_document.this[0].json
}

resource "aws_sns_topic_subscription" "this" {
  count     = var.enable_pipeline && var.sns_topic_subscription_email != null ? 1 : 0
  topic_arn = aws_sns_topic.this[0].arn
  protocol  = "email"
  endpoint  = var.sns_topic_subscription_email
}

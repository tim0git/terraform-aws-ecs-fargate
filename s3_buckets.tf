locals {
  s3_lifecycle_templates = yamldecode(file("${path.module}/s3_lifecycle_templates.yml"))

  logging_configuration = {
    target_bucket = var.s3_access_logs_bucket_name
    target_prefix = "${data.aws_caller_identity.current.account_id}-${var.application_name}-deploy-pipeline/"
  }

  logging = var.s3_access_logs_bucket_name == null ? {} : local.logging_configuration
}

module "pipeline_artifacts_bucket" {
  create_bucket = var.enable_pipeline
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "3.6.0"
  force_destroy = true

  bucket = "${data.aws_caller_identity.current.account_id}-${var.application_name}-deploy-pipeline"
  acl    = "private"

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Bucket policies
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  versioning = {
    status     = true
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    bucket_key_enabled = true
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  logging = local.logging

  lifecycle_rule = local.s3_lifecycle_templates.standard_ia_30_glacier_60_delete_365
}

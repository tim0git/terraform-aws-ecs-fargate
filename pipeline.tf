locals {
  ecr_repository_name = regex(".*/(.*?):", var.container_definition.image)[0]
  image_tag           = regex("(.*):(.*)", var.container_definition.image)[1]
}

resource "aws_codepipeline" "this" {
  count    = var.enable_pipeline ? 1 : 0
  name     = "${var.application_name}-deploy-pipeline"
  role_arn = aws_iam_role.code_pipeline[0].arn

  artifact_store {
    location = module.pipeline_artifacts_bucket.s3_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Image"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["MyImage"]

      configuration = {
        RepositoryName = local.ecr_repository_name
        ImageTag       = local.image_tag
      }
      run_order = 1
    }

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName       = aws_codecommit_repository.this[0].repository_name
        BranchName           = "main"
        PollForSourceChanges = "false" #set to false to avoid double trigger of pipeline, other trigger is via event-bridge set in codecommit.json file in cloudwatch folder
      }

      run_order = 1
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["SourceArtifact", "MyImage"]
      version         = "1"

      configuration = {
        AppSpecTemplateArtifact        = "SourceArtifact",
        AppSpecTemplatePath            = "appspec.yaml",
        TaskDefinitionTemplateArtifact = "SourceArtifact",
        TaskDefinitionTemplatePath     = "taskdef.json",
        ApplicationName                = aws_codedeploy_app.this[0].name,
        DeploymentGroupName            = aws_codedeploy_deployment_group.this[0].app_name,
        Image1ArtifactName             = "MyImage",
        Image1ContainerName            = "IMAGE1_NAME"
      }
    }
  }
}


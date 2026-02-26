resource "aws_codestarconnections_connection" "github" {
  name          = "github-ecs-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "ecs_pipeline" {
  name     = "ecs-bluegreen-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
  }

  # ---------------- SOURCE ----------------
  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "adnan-signiance/Multi_Tier_Web_App-v1"
        BranchName           = "main"
        DetectChanges        = "true"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  # ---------------- BUILD ----------------
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.ecs-bluegreen.name
      }
    }
  }

  # ---------------- DEPLOY (BLUE–GREEN) ----------------
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ApplicationName                = aws_codedeploy_app.ecs-bluegreen.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.ecs-bluegreen.deployment_group_name
        AppSpecTemplateArtifact        = "build_output"
        AppSpecTemplatePath            = "appspec.yaml"
        TaskDefinitionTemplateArtifact = "build_output"
        TaskDefinitionTemplatePath     = "taskdef.json"
      }
    }
  }
}

resource "aws_codestarnotifications_notification_rule" "pipeline_notifications_adnan" {
  name         = "pipeline-notifications-adnan"
  detail_type  = "FULL"
  resource     = aws_codepipeline.ecs_pipeline.arn

  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-stage-execution-started",
    "codepipeline-pipeline-stage-execution-succeeded",
    "codepipeline-pipeline-stage-execution-failed"
  ]

  target {
    address = var.sns_topic_arn
    type    = "SNS"
  }
}
resource "aws_codebuild_project" "ecs-bluegreen" {
  name         = "ecs-bluegreen-build"
  service_role = var.codebuild_role_arn

  build_timeout = 15

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true # REQUIRED for Docker build

    environment_variable {
      name  = "FRONTEND_ECR"
      value = var.frontend_ecr_url
    }

    environment_variable {
      name  = "BACKEND_ECR"
      value = var.backend_ecr_url
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "TASK_EXECUTION_ROLE_ARN"
      value = var.ecs_task_execution_role_arn
    }

    environment_variable {
      name  = "SECRET_ARN"
      value = var.secret_arn
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

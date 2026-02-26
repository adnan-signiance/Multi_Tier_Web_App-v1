# -------------------------------------------------------
# IAM Role for ECS EC2 instances
# -------------------------------------------------------
resource "aws_iam_role" "ecs_instance_role_adnan" {
  name = "ecs-instance-role-adnan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# ECS core permissions (register container instance, poll for tasks)
resource "aws_iam_role_policy_attachment" "ecs_instance_attach_adnan" {
  role       = aws_iam_role.ecs_instance_role_adnan.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# ECR permissions (pull images from ECR)
resource "aws_iam_role_policy_attachment" "ecr_read_adnan" {
  role       = aws_iam_role.ecs_instance_role_adnan.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# CloudWatch Logs permissions (push container logs)
resource "aws_iam_role_policy_attachment" "cloudwatch_logs_adnan" {
  role       = aws_iam_role.ecs_instance_role_adnan.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# SSM permissions (Session Manager instead of SSH)
resource "aws_iam_role_policy_attachment" "ssm_adnan" {
  role       = aws_iam_role.ecs_instance_role_adnan.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -------------------------------------------------------
# Instance Profile (wraps the role for EC2 attachment)
# -------------------------------------------------------
resource "aws_iam_instance_profile" "ecs_adnan" {
  name = "ecs-instance-profile-adnan"
  role = aws_iam_role.ecs_instance_role_adnan.name
}

# -------------------------------------------------------
# ECS Task Execution Role (ECR, Logs, Secrets Manager)
# -------------------------------------------------------
resource "aws_iam_role" "ecs_task_execution_role_adnan" {
  name = "ecs-task-execution-role-adnan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Default ECS execution permissions (ECR + CloudWatch logs)
resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach_adnan" {
  role       = aws_iam_role.ecs_task_execution_role_adnan.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -------------------------------------------------------
# Secrets Manager access (LEAST PRIVILEGE)
# -------------------------------------------------------
resource "aws_iam_policy" "ecs_task_secrets_policy_adnan" {
  name = "ecs-task-secrets-policy-adnan"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = var.secret_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_secrets_attach_adnan" {
  role       = aws_iam_role.ecs_task_execution_role_adnan.name
  policy_arn = aws_iam_policy.ecs_task_secrets_policy_adnan.arn
}


resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-ecs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codebuild_logs" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# CodeBuild needs S3 access to read pipeline source artifacts and write build output
resource "aws_iam_role_policy" "codebuild_s3_policy" {
  name = "codebuild-s3-artifacts-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_artifacts_arn,
          "${var.s3_artifacts_arn}/*"
        ]
      },
      {
        # Required for CodeBuild to write build reports
        Effect = "Allow"
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-ecs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codedeploy.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# Inline policy: exact permissions CodeDeploy needs for ECS blue-green
resource "aws_iam_role_policy" "codedeploy_ecs_policy" {
  name = "codedeploy-ecs-bluegreen-policy"
  role = aws_iam_role.codedeploy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:CreateTaskSet",
          "ecs:UpdateServicePrimaryTaskSet",
          "ecs:DeleteTaskSet",
          "ecs:UpdateService",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:ModifyRule"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarms",
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-ecs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # S3 Artifacts
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.s3_artifacts_arn,
          "${var.s3_artifacts_arn}/*"
        ]
      },

      # CodeBuild
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Resource = "*" # Scoped to account/region by IAM; avoids cicd<->iam circular dependency
      },

      # CodeDeploy
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentGroup",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:StopDeployment"
        ]
        Resource = "*"
      },

      # ECS — CodeDeployToECS provider registers the task definition itself
      {
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeServices",
          "ecs:CreateTaskSet",
          "ecs:UpdateServicePrimaryTaskSet",
          "ecs:DeleteTaskSet",
          "ecs:UpdateService"
        ]
        Resource = "*"
      },

      # CodeStar GitHub connection
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = "*" # Scoped to account/region; avoids cicd<->iam circular dependency
      },

      # Pass roles to services
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

# -------------------------------------------------------
# SNS Topic Policy
# Resource-based policy granting AWS service principals
# permission to publish to the SNS topic.
#   - codestar-notifications → pipeline event notifications
#   - cloudwatch             → alarm notifications
# The SourceAccount condition prevents confused-deputy attacks.
# -------------------------------------------------------
data "aws_caller_identity" "current" {}

resource "aws_sns_topic_policy" "notifications_policy" {
  arn = var.sns_topic_arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCodeStarNotificationsPublish"
        Effect = "Allow"
        Principal = {
          Service = "codestar-notifications.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = var.sns_topic_arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowCloudWatchAlarmsPublish"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = var.sns_topic_arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

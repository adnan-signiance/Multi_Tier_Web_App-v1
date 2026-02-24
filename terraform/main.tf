terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

# -------------------------------------------------------
# Secrets Manager — store DB credentials securely
# Created first so RDS and ECS can reference it
# -------------------------------------------------------
module "secretsmanager" {
  source = "./modules/secretsmanager"

  secret_name = "rds/mysql/credentials"
  db_username = var.db_username
  db_password = var.db_password
}

# -------------------------------------------------------
# VPC — networking foundation (NAT Gateway for private subnets)
# -------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"
}

# -------------------------------------------------------
# S3 — artifact bucket for CodePipeline
# -------------------------------------------------------
module "s3" {
  source = "./modules/s3"
}

# -------------------------------------------------------
# IAM — roles and instance profiles for ECS EC2 + CI/CD
# -------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  secret_arn       = module.secretsmanager.secret_arn
  s3_artifacts_arn = module.s3.bucket_arn
}

# -------------------------------------------------------
# ALB — Application Load Balancer (public-facing)
# -------------------------------------------------------
module "alb" {
  source = "./modules/alb"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
  alb_security_group_id = module.vpc.alb_security_group_id
}

# -------------------------------------------------------
# RDS — MySQL database in private subnets
# -------------------------------------------------------
module "rds" {
  source = "./modules/rds"

  db_name                = "my_app_db"
  db_instance_class      = "db.t3.micro"
  db_username            = module.secretsmanager.db_username
  db_password            = module.secretsmanager.db_password
  db_subnet_group_name   = module.vpc.db_subnet_group_name
  vpc_security_group_ids = [module.vpc.rds_security_group_id]
}

# -------------------------------------------------------
# ECS — cluster + EC2 ASG + task definition + service
# -------------------------------------------------------
module "ecs" {
  source = "./modules/ecs"

  private_subnets             = module.vpc.private_subnet_ids
  ecs_security_group_id       = module.vpc.ecs_security_group_id
  ecs_instance_profile_arn    = module.iam.ecs_instance_profile_arn
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  db_host                     = module.rds.db_address
  db_name                     = "my_app_db"
  db_username                 = module.secretsmanager.db_username
  db_password                 = module.secretsmanager.db_password
  target_group_arn            = module.alb.target_group_arn
  aws_region                  = var.region
  secret_arn                  = module.secretsmanager.secret_arn
}

# -------------------------------------------------------
# CI/CD — CodePipeline + CodeBuild + CodeDeploy (Blue-Green)
# -------------------------------------------------------
module "cicd" {
  source = "./modules/cicd"

  codebuild_role_arn          = module.iam.codebuild_role_arn
  codedeploy_role_arn         = module.iam.codedeploy_role_arn
  codepipeline_role_arn       = module.iam.codepipeline_role_arn
  s3_bucket_name              = module.s3.bucket_name
  aws_region                  = var.region
  frontend_ecr_url            = module.ecs.frontend_ecr_repository_url
  backend_ecr_url             = module.ecs.backend_ecr_repository_url
  ecs_cluster_name            = module.ecs.cluster_name
  ecs_service_name            = module.ecs.ecs_service_name
  alb_listener_arn            = module.alb.alb_listener_arn
  blue_target_group_name      = module.alb.blue_target_group_name
  green_target_group_name     = module.alb.green_target_group_name
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  secret_arn                  = module.secretsmanager.secret_arn
  db_host                     = module.rds.db_address
  db_name                     = "my_app_db"
}

# -------------------------------------------------------
# CloudFront — CDN in front of ALB
# -------------------------------------------------------
module "cloudfront" {
  source = "./modules/cloudfront"

  alb_dns_name = module.alb.alb_dns_name
}

# -------------------------------------------------------
# SNS — alerting topic
# -------------------------------------------------------
module "sns" {
  source = "./modules/sns"
}

# -------------------------------------------------------
# CloudWatch — monitoring and alarms
# -------------------------------------------------------
module "cloudwatch" {
  source = "./modules/cloudwatch"

  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.ecs_service_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  sns_topic_arn           = module.sns.sns_topic_arn
}

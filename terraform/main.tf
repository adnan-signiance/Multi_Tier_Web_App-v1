terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source = "./modules/ec2"

  subnet_id         = module.vpc.private_subnet_id
  security_group_id = module.vpc.ec2_security_group_id
  ami_id            = var.ami_id[var.region]
}

module "alb" {
  source = "./modules/alb"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
  alb_security_group_id = module.vpc.alb_security_group_id
  ec2_instance_id       = module.ec2.instance_id
}

module "cloudfront" {
  source = "./modules/cloudfront"

  alb_dns_name = module.alb.alb_dns_name
}

module "sns" {
  source = "./modules/sns"
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  ec2_instance_id         = module.ec2.instance_id
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  sns_topic_arn           = module.sns.sns_topic_arn
}

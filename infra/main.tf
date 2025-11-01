terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "my-terraform-state-dev"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

module "vpc" {
  source = "./modules/vpc"
  vpc_name = var.vpc_name
}

module "iam" {
  source = "./modules/iam"
  eks_cluster_name = var.cluster_name
}

module "eks" {
  source = "./modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  node_iam_role_arn = module.iam.node_role_arn
}

module "monitoring" {
  source = "./modules/monitoring"
  alert_email = var.alert_email
  monthly_budget_limit = var.monthly_budget_limit
}

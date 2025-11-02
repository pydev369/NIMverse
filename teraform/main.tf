# Main configuration file that references all modules
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Will be configured after initial apply
    bucket = "nvidia-hackathon-tfstate"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "nvidia-hackathon"
      Environment = var.environment
      ManagedBy   = "terraform"
      GitHubUser  = var.github_username
    }
  }
}
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "github_username" {
  description = "GitHub username for resource naming"
  type        = string
  default     = "pydev369"
}

variable "existing_ecr_repo_url" {
  description = "Existing ECR repository URL"
  type        = string
  default     = "770494478419.dkr.ecr.us-east-1.amazonaws.com/nvidia-agent-backend"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "nvidia-hackathon-cluster"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "hackathon"
}
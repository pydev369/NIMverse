variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "github_username" {
  description = "Your GitHub username for CI/CD"
  type        = string
  default     = "gh-actions-hacks"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "nvidia-agent-backend"
}
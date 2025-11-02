variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "github_username" {
  description = "Your GitHub username for CI/CD"
  type        = string
  default     = "pydev369"
}

variable "existing_ecr_repository_name" {
  description = "Existing ECR repository name"
  type        = string
  default     = "nvidia-agent-backend"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "nvidia-hackathon"
}

variable "nvidia_models" {
  description = "NVIDIA models to deploy"
  type        = map(string)
  default = {
    llm_model    = "nvidia/Llama-3.1-Nemotron-Nano-8B-v1"
    embed_model  = "nvidia/llama-3_2-nemoretriever-300m-embed-v1"
  }
}

variable "s3_bucket_name" {
  description = "S3 bucket for model storage and Terraform state"
  type        = string
  default     = "nvidia-models-pydev369"
}
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "nvidia-hackathon-cluster"
}
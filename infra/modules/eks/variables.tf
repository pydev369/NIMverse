variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "agentic-cluster"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

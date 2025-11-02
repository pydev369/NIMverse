output "existing_ecr_repository_url" {
  description = "Existing ECR Repository URL"
  value       = data.aws_ecr_repository.nvidia_agent.repository_url
}

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.nvidia_hackathon.name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API Server Endpoint"
  value       = aws_eks_cluster.nvidia_hackathon.endpoint
}

output "eks_cluster_version" {
  description = "EKS Cluster Version"
  value       = aws_eks_cluster.nvidia_hackathon.version
}

output "s3_bucket_name" {
  description = "S3 Bucket for Model Storage"
  value       = aws_s3_bucket.nvidia_models.bucket
}

output "github_actions_access_key" {
  description = "GitHub Actions IAM Access Key ID"
  value       = aws_iam_access_key.github_actions.id
  sensitive   = true
}

output "github_actions_secret_key" {
  description = "GitHub Actions IAM Secret Access Key"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.eks_vpc.id
}

output "node_group_status" {
  description = "EKS Node Group Status"
  value       = aws_eks_node_group.gpu_nodes.status
}

output "nvidia_models" {
  description = "NVIDIA Models to be deployed"
  value       = var.nvidia_models
}

output "deployment_commands" {
  description = "Useful deployment commands"
  value = <<EOT
Configure kubectl:
  aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.nvidia_hackathon.name}

Check cluster status:
  kubectl get nodes
  kubectl get pods -A

Deploy NVIDIA NIM:
  kubectl apply -f kubernetes/nim-deployment.yaml

GitHub Secrets to set:
  AWS_ACCESS_KEY_ID: ${aws_iam_access_key.github_actions.id}
  AWS_SECRET_ACCESS_KEY: [hidden]
  ECR_REPOSITORY: ${var.existing_ecr_repository_name}
  S3_BUCKET: ${aws_s3_bucket.nvidia_models.bucket}
EOT
}
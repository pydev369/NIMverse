output "ecr_repository_url" {
  description = "ECR Repository URL for Docker pushes"
  value       = aws_ecr_repository.nvidia_agent.repository_url
}

output "eks_cluster_name" {
  description = "EKS Cluster Name for kubeconfig"
  value       = aws_eks_cluster.nvidia_hackathon.name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API Server Endpoint"
  value       = aws_eks_cluster.nvidia_hackathon.endpoint
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
  description = "VPC ID created for EKS"
  value       = aws_vpc.eks_vpc.id
}

output "terraform_apply_command" {
  description = "Command to run Terraform apply"
  value       = "terraform apply -auto-approve"
}

output "next_steps" {
  description = "Next steps after Terraform completes"
  value = <<EOT
Next Steps:
1. Save GitHub Actions credentials to GitHub Secrets
2. Run: aws eks update-kubeconfig --region us-east-1 --name nvidia-hackathon-cluster
3. Test EKS connection: kubectl get nodes
4. Push code to trigger GitHub Actions deployment
EOT
}
output "node_role_arn" {
  description = "ARN of the node IAM role"
  value       = aws_iam_role.eks_node_role.arn
}

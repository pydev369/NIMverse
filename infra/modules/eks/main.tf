module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.0"

  cluster_name = var.cluster_name
  cluster_version = "1.30"
  vpc_id       = var.vpc_id
  subnet_ids   = var.subnet_ids

  eks_managed_node_groups = {
    gpu_nodes = {
      desired_size = 0
      min_size     = 0
      max_size     = 2
      instance_types = ["g5.xlarge"]
      capacity_type  = "SPOT"
      labels = { role = "gpu" }
    }

    app_nodes = {
      desired_size = 1
      instance_types = ["t3.medium"]
      labels = { role = "app" }
    }
  }

  tags = {
    Environment = "dev"
  }
}

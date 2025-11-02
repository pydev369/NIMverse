# Data sources for existing resources
data "aws_ecr_repository" "nvidia_agent" {
  name = var.existing_ecr_repository_name
}

# VPC for EKS - CREATE FIRST (no EKS dependencies)
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Network = "eks"
  }
}

resource "aws_subnet" "eks_subnets" {
  count = 2

  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = "${var.aws_region}${count.index % 2 == 0 ? "a" : "b"}"

  map_public_ip_on_launch = true

  # REMOVED EKS cluster reference from tags to break cycle
  tags = {
    Name = "${var.project_name}-subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "eks_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "${var.project_name}-rt"
  }
}

resource "aws_route_table_association" "eks_rta" {
  count = 2

  subnet_id      = aws_subnet.eks_subnets[count.index].id
  route_table_id = aws_route_table.eks_rt.id
}

# Key pair for node access
resource "aws_key_pair" "eks_worker" {
  key_name   = "${var.project_name}-worker-key"
  public_key = file("${path.module}/ssh-key.pub") # Use local file to avoid cycles

  tags = {
    Project = var.project_name
  }
}

# EKS Cluster - DEPENDS ON VPC/SUBNETS
resource "aws_eks_cluster" "nvidia_hackathon" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.28"

  vpc_config {
    subnet_ids              = aws_subnet.eks_subnets[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name        = "${var.project_name}-eks-cluster"
    GPU         = "enabled"
    NVIDIAModel = var.nvidia_models.llm_model
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

# EKS Node Group with GPU support - DEPENDS ON CLUSTER
resource "aws_eks_node_group" "gpu_nodes" {
  cluster_name    = aws_eks_cluster.nvidia_hackathon.name
  node_group_name = "gpu-nodes"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = aws_subnet.eks_subnets[*].id

  capacity_type  = "ON_DEMAND"
  instance_types = ["g4dn.xlarge"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  ami_type       = "AL2_x86_64_GPU"
  disk_size      = 50

  remote_access {
    ec2_ssh_key = aws_key_pair.eks_worker.key_name
  }

  tags = {
    Name        = "gpu-worker-node"
    GPU         = "nvidia-t4"
    Project     = var.project_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
  ]
}

# NOW add the Kubernetes tags to subnets AFTER EKS cluster is created
resource "aws_ec2_tag" "eks_subnet_tags" {
  for_each = {
    for idx, subnet in aws_subnet.eks_subnets : idx => subnet.id
  }

  resource_id = each.value
  key         = "kubernetes.io/cluster/${aws_eks_cluster.nvidia_hackathon.name}"
  value       = "shared"

  depends_on = [aws_eks_cluster.nvidia_hackathon]
}
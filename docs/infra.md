Perfect — you want a **complete, professional Terraform setup** to:

* Build a minimal but real **EKS cluster** (for GPU + app + UI pods)
* Configure **networking, IAM, roles, security, and monitoring** correctly (no fluff)
* Add **AWS Budgets, CloudWatch alarms, and cost monitoring**
* Include **repo structure** and **VS Code setup** for linting, bug fixing, and smart iteration

Below is a **realistic DevOps-grade setup** designed for development/hackathon scale (not enterprise bloat), fully modular, with safety and cost control built-in.

---

# 🧱 1. Repository Structure

```
agentic-app/
│
├── README.md
├── .gitignore
├── .vscode/
│   ├── settings.json
│   └── launch.json
│
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── backend.tf
│   ├── modules/
│   │   ├── vpc/
│   │   ├── eks/
│   │   ├── iam/
│   │   ├── monitoring/
│   │   └── ecr/
│   ├── scripts/
│   │   ├── scale_gpu.sh
│   │   └── cleanup.sh
│   └── README.md
│
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── src/
│   │   ├── main.py
│   │   ├── agents/
│   │   │   ├── orchestrator.py
│   │   │   ├── tools/
│   │   │   │   ├── retriever.py
│   │   │   │   ├── summarizer.py
│   │   │   │   └── analytics.py
│   │   ├── workflows/
│   │   │   ├── graph_agent.py
│   │   │   └── memory_store.py
│   │   └── utils/
│   │       ├── config_loader.py
│   │       ├── logger.py
│   │       └── aws_helpers.py
│   ├── tests/
│   │   ├── test_agent.py
│   │   └── test_retrieval.py
│   └── README.md
│
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   ├── vite.config.js
│   ├── src/
│   │   ├── App.tsx
│   │   ├── components/
│   │   │   ├── AgentDashboard.tsx
│   │   │   ├── CostMonitor.tsx
│   │   │   └── ChatPanel.tsx
│   │   ├── hooks/
│   │   │   └── useAgenticAPI.ts
│   │   ├── styles/
│   │   │   └── globals.css
│   │   └── lib/
│   │       ├── api.ts
│   │       └── constants.ts
│   └── README.md
│
├── manifests/
│   ├── nvidia-nim-llama.yaml
│   ├── nvidia-embedqa.yaml
│   ├── agentic-backend.yaml
│   ├── agentic-frontend.yaml
│   └── namespace.yaml
│
├── ci-cd/
│   ├── github-actions/
│   │   └── deploy.yml
│   ├── docker-compose.dev.yml
│   └── k8s-deploy.sh
│
└── docs/
    ├── architecture-diagram.png
    ├── system-design.md
    ├── cost-optimization.md
    ├── deployment-guide.md
    └── troubleshooting.md

```

---

# ⚙️ 2. `main.tf` (root)

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "my-terraform-state-dev"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

module "vpc" {
  source = "./modules/vpc"
  vpc_name = var.vpc_name
}

module "iam" {
  source = "./modules/iam"
  eks_cluster_name = var.cluster_name
}

module "eks" {
  source = "./modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  node_iam_role_arn = module.iam.node_role_arn
}

module "monitoring" {
  source = "./modules/monitoring"
  alert_email = var.alert_email
  monthly_budget_limit = var.monthly_budget_limit
}
```

---

# 🌐 3. VPC Module (`modules/vpc/main.tf`)

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "dev"
  }
}
```

---

# 🧑‍💻 4. IAM Module (`modules/iam/main.tf`)

```hcl
resource "aws_iam_role" "eks_node_role" {
  name = "${var.eks_cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ])
  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

output "node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}
```

---

# ☸️ 5. EKS Module (`modules/eks/main.tf`)

```hcl
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
```

---

# 🕵️ 6. Monitoring & Cost Control Module (`modules/monitoring/`)

## `budget.tf`

```hcl
resource "aws_budgets_budget" "dev_budget" {
  name = "DevBudget"
  budget_type = "COST"
  limit_amount = var.monthly_budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    threshold = 50
    threshold_type = "PERCENTAGE"
    notification_type = "ACTUAL"

    subscriber {
      subscription_type = "EMAIL"
      address = var.alert_email
    }
  }

  notification {
    comparison_operator = "GREATER_THAN"
    threshold = 80
    threshold_type = "PERCENTAGE"
    notification_type = "ACTUAL"

    subscriber {
      subscription_type = "EMAIL"
      address = var.alert_email
    }
  }
}
```

## `cloudwatch.tf`

```hcl
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "EstimatedChargesOverLimit"
  namespace           = "AWS/Billing"
  metric_name         = "EstimatedCharges"
  dimensions          = { Currency = "USD" }
  statistic           = "Maximum"
  period              = 21600
  evaluation_periods  = 1
  threshold           = var.monthly_budget_limit * 0.5
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_description   = "Alert when estimated charges exceed 50% budget"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

## `sns.tf`

```hcl
resource "aws_sns_topic" "alerts" {
  name = "cost-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
```

---

# 🧰 7. Scripts

### `scripts/scale_gpu.sh`

```bash
#!/bin/bash
# Scales GPU node group on/off for cost control

CLUSTER_NAME="agentic-cluster"
NODEGROUP_NAME="gpu_nodes"
REGION="us-east-1"

ACTION=$1

if [ "$ACTION" == "up" ]; then
  echo "Scaling GPU nodes up..."
  aws eks update-nodegroup-config --cluster-name $CLUSTER_NAME \
      --nodegroup-name $NODEGROUP_NAME --scaling-config minSize=1,maxSize=2,desiredSize=1 --region $REGION
elif [ "$ACTION" == "down" ]; then
  echo "Scaling GPU nodes down..."
  aws eks update-nodegroup-config --cluster-name $CLUSTER_NAME \
      --nodegroup-name $NODEGROUP_NAME --scaling-config minSize=0,maxSize=2,desiredSize=0 --region $REGION
else
  echo "Usage: ./scale_gpu.sh up|down"
fi
```

---

# 🧑‍💻 8. VS Code Setup for Terraform

### `.vscode/settings.json`

```json
{
  "terraform.languageServer": {
    "enabled": true,
    "args": ["serve"],
    "path": "terraform-ls"
  },
  "editor.formatOnSave": true,
  "terraform-ls.experimentalFeatures": {
    "validateOnSave": true
  },
  "files.associations": {
    "*.tf": "terraform"
  }
}
```

### Install extensions:

* HashiCorp Terraform (`hashicorp.terraform`)
* AWS Toolkit
* YAML / JSON extensions for config
* Terraform CLI validation:

  ```bash
  terraform init
  terraform fmt -recursive
  terraform validate
  ```

---

# 📊 9. Monitoring AWS Costs (from Console)

**Navigate in AWS Console →**

1. **Billing & Cost Management → Budgets**

   * See total and per-service costs.
   * Check if your Terraform budget resource reflects here.
2. **CloudWatch → Metrics → Billing**

   * Enable “EstimatedCharges” metrics.
   * View your spending by service and create alarms manually if needed.
3. **AWS Cost Explorer**

   * Enable “Cost Explorer”.
   * Filter by Service (EKS, EC2, ECR, S3).
   * Filter by linked accounts (if multi-account).
4. **Daily Cost Breakdown**

   * Activate Cost Anomaly Detection for automatic alerts on unusual charges.

---

# 💡 10. Common Pitfalls & Pro Tips

✅ **Always run `terraform plan`** before apply.
✅ **Keep state remote (S3 + DynamoDB lock)** for consistency.
✅ **Avoid hardcoding credentials** – use AWS CLI profile or IAM Role.
✅ **Tag all resources (`env`, `owner`, `project`)** for cost tracking.
✅ **Scale GPU nodes to 0 when idle**.
✅ **Use Spot for GPU nodes** during testing to cut 70–80% cost.
✅ **Set ECR lifecycle rule** to delete untagged images after 3 days.
✅ **Enable S3 lifecycle rules** for logs/objects older than 7 days.

---

# 🚀 11. Getting Started Guide

### Step 1: Setup AWS & Terraform

```bash
aws configure
terraform init
terraform plan
terraform apply -auto-approve
```

### Step 2: Verify

```bash
aws eks list-clusters
aws eks describe-cluster --name agentic-cluster
```

### Step 3: Deploy NIM microservices

Use your container manifests or Helm chart to deploy:

```bash
kubectl apply -f nvidia-nim-llama-deployment.yaml
kubectl apply -f embedqa-nim-deployment.yaml
kubectl apply -f react-ui.yaml
kubectl apply -f python-agent.yaml
```

### Step 4: Monitor & Scale

```bash
./scripts/scale_gpu.sh up   # Start GPU
./scripts/scale_gpu.sh down # Stop GPU to save cost
```

### Step 5: Monitor Cost

* Go to AWS Console → **Billing Dashboard** → “Budgets”.
* Check CloudWatch → “Alarms” → “EstimatedCharges”.
* Inspect **Cost Explorer** for per-service daily trends.

---

Would you like me to **generate this entire Terraform repo as downloadable `.zip`** (ready to open in VS Code), with:

* all modules prefilled,
* remote state backend setup optional,
* and sample Helm manifest placeholders for your Llama + EmbedQA + UI + Agent pods?

It’ll save you 2–3 hours of setup time.

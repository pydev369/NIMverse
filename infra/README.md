# Infrastructure Setup

This directory contains all the Terraform code to set up the AWS infrastructure for the agentic application with NVIDIA NIM.

## Modules

- **VPC**: Sets up the virtual private cloud with public and private subnets
- **IAM**: Creates IAM roles for EKS nodes
- **EKS**: Creates the EKS cluster with GPU and application node groups
- **Monitoring**: Sets up AWS Budgets and CloudWatch alarms for cost control

## Prerequisites

- Terraform >= 1.6.0
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create EKS, VPC, IAM, and monitoring resources

## AWS Credentials Setup

Before running Terraform, ensure your AWS credentials are properly configured:

1. Install AWS CLI if not already installed:

   ```bash
   # For Windows (using Chocolatey)
   choco install awscli
   
   # For macOS (using Homebrew)
   brew install awscli
   
   # For Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

2. Configure your AWS credentials:

   ```bash
   aws configure --profile your-profile-name
   ```

   Enter your:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region (us-east-1)
   - Default output format (json)

3. Verify configuration:

   ```bash
   aws sts get-caller-identity --profile your-profile-name
   ```

## Variables Configuration

Update `terraform.tfvars` with your specific values:

- `alert_email`: Your email for cost alerts
- `aws_profile`: Your configured AWS profile name
- `cluster_name`: Unique name for your EKS cluster
- `vpc_name`: Unique name for your VPC

## Terraform Workflow

### 1. Initialize Terraform

```bash
cd infra
terraform init
```

This downloads required providers and configures the backend.

### 2. Validate Configuration

```bash
terraform validate
```

Check for syntax errors and configuration issues.

### 3. Format Code

```bash
terraform fmt -recursive
```

Ensure consistent formatting across all Terraform files.

### 4. Plan Infrastructure

```bash
terraform plan
```

Review what Terraform will create, modify, or destroy. Always check this output carefully.

### 5. Apply Infrastructure

```bash
terraform apply
```

Manually review and confirm the changes. For automated environments:

```bash
terraform apply -auto-approve
```

### 6. Scale GPU Nodes

To start GPU nodes for inference:

```bash
./scripts/scale_gpu.sh up
```

To stop GPU nodes and save costs:

```bash
./scripts/scale_gpu.sh down
```

## Debugging Strategies

### Common Debugging Commands

1. Check current state:

   ```bash
   terraform state list
   terraform state show module.eks.aws_eks_cluster.this
   ```

2. Refresh state from AWS:

   ```bash
   terraform refresh
   ```

3. Check for drift:

   ```bash
   terraform plan -refresh-only
   ```

4. Output current values:

   ```bash
   terraform output
   ```

### Troubleshooting EKS Issues

1. Update kubeconfig:

   ```bash
   aws eks update-kubeconfig --name your-cluster-name --profile your-profile-name
   ```

2. Test kubectl connection:

   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

3. Check node group status:

   ```bash
   aws eks describe-nodegroup --cluster-name your-cluster-name --nodegroup-name gpu_nodes
   ```

## Common Pitfalls and Hard Lessons

### 1. State Management

- **Never** manually delete resources in AWS that are managed by Terraform
- Always use `terraform destroy` or targeted destroy: `terraform destroy -target module.eks`
- Backup your state file regularly if using local state

### 2. IAM and Permissions

- Ensure your AWS user has AdministratorAccess or equivalent permissions
- Some resources require specific service roles that may take time to propagate
- If you get "AccessDenied" errors, check both your user permissions and service role permissions

### 3. EKS Cluster Creation

- Cluster creation can take 10-15 minutes, be patient
- GPU node groups may fail if there's insufficient capacity in your region
- Spot instances can be terminated at any time by AWS

### 4. Cost Control

- Always set up budget alerts before deploying
- Monitor your spending regularly in AWS Cost Explorer
- GPU instances (g5.xlarge) can cost $1-2/hour when running

### 5. Networking

- Ensure your VPC has enough IP addresses for your node groups
- NAT Gateway is required for private subnets to access the internet
- Security groups and IAM roles must be correctly configured for node communication

### 6. Terraform Best Practices

- Always run `terraform plan` before `terraform apply`
- Use version control for your Terraform code
- Pin provider versions to avoid unexpected changes
- Use modules to organize and reuse code
- Store state remotely (S3 + DynamoDB) for team collaboration

## Destroying Infrastructure

To tear down all resources:

```bash
terraform destroy
```

To tear down specific modules:

```bash
terraform destroy -target module.eks
terraform destroy -target module.vpc
```

**Warning**: This will permanently delete all resources including EKS cluster, VPC, and monitoring configurations.

## Git Repository Setup

To set up the Git repository for this infrastructure code:

1. Initialize Git repository (if not already done):

   ```bash
   git init
   ```

2. Add and commit all files:

   ```bash
   git add .
   git commit -m "Initial commit of Terraform infrastructure"
   ```

3. If you encounter "remote origin already exists" error:

   ```bash
   # Check existing remotes
   git remote -v
   
   # Remove existing origin remote
   git remote remove origin
   
   # Add new origin remote
   git remote add origin https://github.com/your-username/your-repo.git
   
   # Verify remote was added
   git remote -v
   ```

4. Push to remote repository:

   ```bash
   git push -u origin main

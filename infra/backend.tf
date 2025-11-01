# Terraform backend configuration
# This configuration is also defined in main.tf
# Having it in a separate file makes it easier to manage

terraform {
  backend "s3" {
    bucket = "my-terraform-state-dev"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

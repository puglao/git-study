terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  default_tags {
      tags = {
      managed_by = "terraform"
      terraform_root = "terraform_pipeline"
      repository = var.pipeline_repo
      environment = var.environment
      }
  }
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
   backend "s3" {
     # backend-config is stored in backend.hcl
     # Use "terraform init -backend-config=backend.hcl" to setup backend
   }

}

provider "aws" {
}

resource "aws_vpc" "example" {
    cidr_block = "10.0.0.0/16"
}
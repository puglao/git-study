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

# Configure the AWS Provider
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      managed_by     = "terraform"
      terraform_root = "terraform_pipeline"
      repository     = var.pipeline_repo
      environment    = var.environment
    }
  }
}


resource "random_id" "rid" {
byte_length = 2
}

resource "local_file" "backend_config" {
    content     = <<-EOT
    bucket = "${aws_s3_bucket.tfstate_bucket.id}"
    key = "tf-backend/terraform.tfstate"
    region = "${var.region}"
    dynamodb_table = "${aws_dynamodb_table.tf_state_lock.id}"
    encrypt = true
EOT
    filename = "./backend.hcl"
    file_permission = "0600"
}
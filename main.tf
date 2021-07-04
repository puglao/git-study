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

resource "local_file" "pipeline_backend" {
  content         = <<-EOT
    bucket = "${aws_s3_bucket.tfstate_bucket.id}"
    key = "${var.backend_config.pipeline_state_key}"
    region = "${var.region}"
    dynamodb_table = "${aws_dynamodb_table.tf_state_lock.id}"
    encrypt = true
EOT
  filename        = "./backend.hcl"
  file_permission = "0600"
}

resource "local_file" "terraform_backend" {
  content         = <<-EOT
    bucket = "${aws_s3_bucket.tfstate_bucket.id}"
    key = "${var.backend_config.terraform_state_key}"
    region = "${var.region}"
    dynamodb_table = "${aws_dynamodb_table.tf_state_lock.id}"
    encrypt = true
EOT
  filename        = "./tf-init/backend.hcl"
  file_permission = "0600"

  provisioner "local-exec" {
    working_dir = "./tf-init"
    command     = <<-EOT
      aws codecommit put-file \
      --repository-name terraform_code_repo \
      --branch-name master \
      --file-content fileb://backend.hcl \
      --file-path /backend.hcl
      aws codecommit put-file \
      --repository-name terraform_code_repo \
      --branch-name master \
      --file-content fileb://main.tf \
      --file-path /main.tf \
      --parent-commit-id $(aws codecommit get-branch --repository-name terraform_code_repo --branch-name master --query "branch.commitId" | tr -d '"')
   EOT
  }
}



variable "region" {
  type        = string
  default     = "ap-east-1"
  description = "aws resources will be created in this region"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "ecr_repo" {
  type        = string
  default     = "devops/terraformbuild"
  description = "ECR repo name for storing terraform build image"
}


variable "code_repo" {
  type        = string
  default     = "terraform_code_repo"
  description = "Codecommit repo for storing terraform code"
}

variable "pipeline_repo" {
  type        = string
  default     = "terraform_pipeline"
  description = "Codecommit repo for storing terraform code of THIS pipeline"
}


variable "tfplan_build_name" {
  type    = string
  default = "terraform_plan"
}


variable "codebuild_cw_log" {
  type = map(string)
  default = {
    group        = "terraform-pipeline"
    plan_stream  = "tf-plan"
    apply_stream = "tf-apply"
  }
}

variable "backend_config" {
  type = map(string)
  default = {
    bucket_name         = "tf-backend"
    log_bucket_name     = "tf-log"
    db_name             = "tf-lock"
    terraform_state_key = "terraform/terraform.tfstate"
    pipeline_state_key  = "tf-backend/terraform.tfstate"
  }
}
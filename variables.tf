variable "region" {
  type = string
  default = "ap-east-1"
  description = "aws resources will be created in this region"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "ecr_repo" {
  type = string
  default = "devops/terraformbuild"
  description = "ECR repo name for storing terraform build image"
}


variable "code_repo" {
  type = string
  default = "terraform_code_repo"
  description = "Codecommit repo for storing terraform code"
}

variable "pipeline_repo" {
  type = string
  default = "terraform_pipeline"
  description = "Codecommit repo for storing terraform code of THIS pipeline"
}
resource "aws_codecommit_repository" "terraform_repo" {
  repository_name = var.code_repo
  description     = "This is repository for storing terraform code"
}



resource "aws_codecommit_repository" "pipeline_repo" {
  repository_name = var.pipeline_repo
  description     = "This is repository for storing pipeline code"
}

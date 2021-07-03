resource "aws_codecommit_repository" "terraform_repo" {
  repository_name = var.code_repo
  description     = "This is repository for storing terraform code"
}


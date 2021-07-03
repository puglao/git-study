resource "aws_ecr_repository" "buildimage_repo" {
  name                 = var.ecr_repo
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
      encryption_type = "AES256"
  }
    provisioner "local-exec" {
        working_dir = "./buildimage"
         #interpreter = ["/bin/bash" ,"-c"]
  command = <<-EOT
    aws ecr get-login-password --region ap-east-1 | docker login --username AWS --password-stdin ${replace("${self.repository_url}", "/amazonaws.com.*$/", "amazonaws.com")}
    docker build -t ${self.repository_url}:latest .
    docker push ${self.repository_url}:latest
  EOT
  }
}


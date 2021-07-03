output "backend" {
  value = {
      bucket = aws_s3_bucket.tfstate_bucket.id
      key = "tf-backend/terraform.tfstate"
      region = var.region
      dynamodb_table = aws_dynamodb_table.tf_state_lock.id
      encrypt = true
  }
}

# bucket = "tf-backend"
# key    = "tf-backend/terraform.tfstate"
# region = "ap-east-1"
# dynamodb_table = "tf-lock"
# encrypt = true
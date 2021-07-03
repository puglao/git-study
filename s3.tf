# Configure S3 bucket
resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = "${var.backend_config.bucket_name}-${random_id.rid.hex}"
  acl    = "private"
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.tf_log_bucket.id
    target_prefix = "logs/tf-backend/"
  }
  tags = {
    Name = var.backend_config.bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate_bucket_block_public" {
  bucket = aws_s3_bucket.tfstate_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



# Create logging bucket
resource "aws_s3_bucket" "tf_log_bucket" {
  bucket = "${var.backend_config.log_bucket_name}-${random_id.rid.hex}"
  acl    = "log-delivery-write"

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 30
    enabled                                = true
    id                                     = "1 month delete"
    tags                                   = {}
    expiration {
      days                         = 30
      expired_object_delete_marker = false
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_log_bucket_block_public" {
  bucket = aws_s3_bucket.tf_log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# Configure tfstate-lock
resource "aws_dynamodb_table" "tf_state_lock" {
  name           = "${var.backend_config.db_name}-${random_id.rid.hex}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = var.backend_config.db_name
  }
}

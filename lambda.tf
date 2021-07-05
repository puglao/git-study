resource "aws_iam_role" "tf_plan_trigger_role" {
  name = "tf_plan_trigger_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_lambda_function" "tf_plan_trigger_lambda" {
  filename      = data.archive_file.tf_plan_trigger.output_path
  function_name = "tf_plan_trigger"
  role          = aws_iam_role.tf_plan_trigger_role.arn
  handler       = "tf_plan_trigger.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = data.archive_file.tf_plan_trigger.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      foo = "bar"
    }
  }
  depends_on = [
    data.archive_file.tf_plan_trigger
  ]
}


data "archive_file" "tf_plan_trigger" {
  type        = "zip"
  source_file = "./tf_plan_trigger.py"
  output_path = "./tf_plan_trigger.zip"
}
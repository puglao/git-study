resource "aws_iam_role" "tf_plan_role" {
  name = "tf_plan_role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "codebuild.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )

  inline_policy {
    name = "tf_plan_ecr_pull"
    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "ecr:GetAuthorizationToken"
            ],
            "Resource" : "*"
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "ecr:PutImage",
              "ecr:InitiateLayerUpload",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload"
            ],
            "Resource" : "${aws_ecr_repository.buildimage_repo.arn}"
          }
        ]
      }
    )
  }

  inline_policy {
    name = "tf_plan_cloudwatch_log"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Resource" : [
            "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:${var.codebuild_cw_log.group}",
            "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:${var.codebuild_cw_log.group}:*"
          ],
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
        }
      ]
    })
  }

  inline_policy {
    name = "tf_plan_codecommit_pull"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Resource" : [
            "${aws_codecommit_repository.terraform_repo.arn}"
          ],
          "Action" : [
            "codecommit:GitPull"
          ]
      }] }
    )
  }

  inline_policy {
    name = "tf_plan_s3_access"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "s3:ListBucket",
          "Resource" : "${aws_s3_bucket.tfstate_bucket.arn}"
        },
        {
          "Effect" : "Allow",
          "Action" : ["s3:GetObject", "s3:PutObject"],
          "Resource" : "${aws_s3_bucket.tfstate_bucket.arn}/"
        }
      ]
    })
  }

  inline_policy {
    name = "tf_plan_lock_access"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DeleteItem"],
          "Resource" : "${aws_dynamodb_table.tf_state_lock.arn}"
        }
      ]
    })
  }


  tags = {
    Name = "tf_plan_codebuild"
  }
}

resource "aws_codebuild_project" "terraform_plan" {
  name                   = var.tfplan_build_name
  description            = "terraform plan when PR occur"
  build_timeout          = 10
  concurrent_build_limit = 1
  service_role           = aws_iam_role.tf_plan_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    image                       = "${aws_ecr_repository.buildimage_repo.repository_url}:latest"
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image_pull_credentials_type = "SERVICE_ROLE"

  }

  source {
    type      = "CODECOMMIT"
    location  = aws_codecommit_repository.terraform_repo.clone_url_http
    buildspec = file("buildspec/tf_plan_buiildspec.yml")
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.codebuild_cw_log.group
      stream_name = var.codebuild_cw_log.plan_stream
    }
  }
}
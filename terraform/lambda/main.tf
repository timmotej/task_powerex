terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
  }

  backend "s3" {
    bucket         = "backend-s3-tf-bucket"
    key            = "pwx/lambda/terraform.tfstate"
    region         = "us-east-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform_up_and_running_locks"
    encrypt        = true
  }

  required_version = ">= 1.2.0"
}

data "aws_caller_identity" "current" {}

data "aws_ecr_repository" "repo" {
  name = local.ecr_repository_name
}

locals {
  prefix              = "pwx"
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = "${local.prefix}_s3_move_lambda"
  ecr_image_tag       = var.image_tag
}

data "aws_ecr_image" "lambda_image" {
  repository_name = local.ecr_repository_name
  image_tag       = local.ecr_image_tag
}

resource "aws_iam_policy" "lambda_pwx_move_s3_and_logs" {
  name        = "lambda_pwx_create_logs"
  description = "Terraform managed policy for pwx lambda docker function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid      = "CreateCloudWatchLogs"
      },
      {
        Action = [
          "codecommit:ListBranches",
          "codecommit:GitPush",
          "codecommit:GitPull",
          "codecommit:GitBranch",
          "codecommit:GetTree",
          "codecommit:GetReferences",
          "codecommit:GetObjectIdentifier",
          "codecommit:GetMergeCommit",
          "codecommit:GetDifferences",
          "codecommit:GetCommitHistory",
          "codecommit:GetCommit",
          "codecommit:CreateCommit",
          "codecommit:BatchGetCommits",
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid      = "CodeCommit"
      },
      {
        Sid    = "VisualEditor1"
        Effect = "Allow"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:us-west-2:032507288228:async-request/mrap/*/*",
          "arn:aws:s3:*:032507288228:accesspoint/*",
          "arn:aws:s3:::*",
          "arn:aws:s3:*:032507288228:storage-lens/*",
          "arn:aws:s3-object-lambda:*:032507288228:accesspoint/*",
          "arn:aws:s3:*:032507288228:job/*",
        ]
      },
      {
        Sid    = "VisualEditor2"
        Effect = "Allow"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::*/*",
          "arn:aws:s3::032507288228:accesspoint/*"
        ]
      },
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = [
          "s3:ListStorageLensConfigurations",
          "s3:ListAccessPointsForObjectLambda",
          "s3:GetAccessPoint",
          "s3:PutAccountPublicAccessBlock",
          "s3:GetAccountPublicAccessBlock",
          "s3:ListAllMyBuckets",
          "s3:ListAccessPoints",
          "s3:PutAccessPointPublicAccessBlock",
          "s3:ListJobs",
          "s3:PutStorageLensConfiguration",
          "s3:ListMultiRegionAccessPoints",
          "s3:CreateJob",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_pwx_s3" {
  name = "lambda_pwx_s3"
  description = "Terraform managed role for pwx lambda docker function"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Action = "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [aws_iam_policy.lambda_pwx_move_s3_and_logs.arn]
}

data "aws_s3_bucket" "bucket_powerex_files_input" {
  bucket  = "bucket-powerex-files-input"
}

# Adding S3 bucket as trigger to my lambda and giving the permissions
resource "aws_s3_bucket_notification" "aws_trigger_lambda_pwx_move_files" {
  bucket = data.aws_s3_bucket.bucket_powerex_files_input.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_move_rename.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "permission_lambda_to_move_files_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_s3_move_rename.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${data.aws_s3_bucket.bucket_powerex_files_input.id}"
}

resource "aws_lambda_function" "lambda_s3_move_rename" {
  function_name = "${local.prefix}_lambda_s3_move"
  role          = aws_iam_role.lambda_pwx_s3.arn
  timeout       = 300
  image_uri     = "${data.aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type  = "Image"
}

output "lambda_function_id" {
  value = aws_lambda_function.lambda_s3_move_rename.id
}

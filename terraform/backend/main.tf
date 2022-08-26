terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
  }

  required_version = ">= 1.2.0"
}
provider "aws" {
  s3_use_path_style           = true
#  skip_credentials_validation = true
#  skip_metadata_api_check     = true
#  skip_requesting_account_id  = true

#  endpoints {
#    apigateway     = "http://localhost:4566"
#    cloudformation = "http://localhost:4566"
#    cloudwatch     = "http://localhost:4566"
#    dynamodb       = "http://localhost:4566"
#    ec2            = "http://localhost:4566"
#    es             = "http://localhost:4566"
#    elasticache    = "http://localhost:4566"
#    firehose       = "http://localhost:4566"
#    iam            = "http://localhost:4566"
#    kinesis        = "http://localhost:4566"
#    lambda         = "http://localhost:4566"
#    rds            = "http://localhost:4566"
#    redshift       = "http://localhost:4566"
#    route53        = "http://localhost:4566"
#    s3             = "http://localhost:4566"
#    secretsmanager = "http://localhost:4566"
#    ses            = "http://localhost:4566"
#    sns            = "http://localhost:4566"
#    sqs            = "http://localhost:4566"
#    ssm            = "http://localhost:4566"
#    stepfunctions  = "http://localhost:4566"
#    sts            = "http://localhost:4566"
#  }
}

resource "aws_s3_bucket" "test-bucket" {
  bucket = "backend-s3-tf-bucket"
}

resource "aws_iam_role" "invocation_role" {
  name = "s3_api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
        #Action = "sts:AssumeRole"
    #"Action": "s3:ListBucket",
    #"Principal": {
    #  "Resource": "arn:aws:s3:::test-bucket"
    #}
}
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.test-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
##terraform {
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 4.27.0"
#    }
#  }
#
#  required_version = ">= 1.2.0"
#}
#
#provider "aws" {
#  # all is defined in env variables in image
#  #profile    = "default"
#  #access_key = $AWS_ACCESS_KEY_ID
#  #secret_key = $AWS_SECRET_ACCESS_KEY
#  #region     = $AWS_DEFAULT_REGION
#}
#
#resource "aws_s3_bucket" "input_bucket" {
#  bucket = "bucket-powerex-files-input"
#
#  tags = {
#    Name        = "Powerex files input"
#    Environment = "test"
#  }
#}
#
#resource "aws_s3_bucket" "output_bucket" {
#  bucket = "bucket-powerex-files-output"
#
#  tags = {
#    Name        = "Powerex files output"
#    Environment = "test"
#  }
#}
#
#resource "aws_ecr_repository" "pwx" {
#  name                 = "pwx_s3_move_lambda"
#  image_tag_mutability = "MUTABLE"
#
#  image_scanning_configuration {
#    scan_on_push = true
#  }
#}
##
##data "aws_ecr_image" "lambda_s3_move_on_coming" {
##  repository_name = "pwx_s3_move_lambda"
##  image_tag       = "0.0.1"
##}

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
  # all is defined in env variables in image
  #profile    = "default"
  #access_key = $AWS_ACCESS_KEY_ID
  #secret_key = $AWS_SECRET_ACCESS_KEY
  #region     = $AWS_DEFAULT_REGION
}

resource "aws_s3_bucket" "input_bucket" {
  bucket = "bucket-powerex-files-input"

  tags = {
    Name        = "Powerex files input"
    Environment = "test"
  }
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "bucket-powerex-files-output"

  tags = {
    Name        = "Powerex files output"
    Environment = "test"
  }
}

resource "aws_ecr_repository" "pwx" {
  name                 = "pwx/entry"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
#
#data "aws_ecr_image" "lambda_s3_move_on_coming" {
#  repository_name = "pwx/entry"
#  image_tag       = "0.0.1"
#}

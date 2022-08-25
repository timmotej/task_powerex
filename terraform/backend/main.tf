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

resource "aws_s3_bucket" "bucket1" {

bucket = var.bucket_name

tags = {

Name = "ExampleS3Bucket"

}

}

resource "aws_s3_bucket_acl" "bucket1" {

bucket = var.bucket_name

acl = "private"

}

resource "aws_s3_bucket_versioning" "bucket_versioning" {

bucket = var.bucket_name

versioning_configuration {

status = "Enabled"

}

}

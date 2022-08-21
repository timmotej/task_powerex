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
  profile    = "default"
  region     = "us-east-1"
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

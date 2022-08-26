variable "aws_region" {
  description = "The AWS region to create the S3 bucket in."
  default = "us-east-1"
}

variable "tf_s3_bucket_name" {
  description = "A unique name for the bucket"
  default = "backend_s3_tf_bucket"
}

variable "terraform_dynamodb_locks_table" {
  description = "A name of the table for terraform locks of tfstate in s3"
  default = "terraform_table_locks"
}

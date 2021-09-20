terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.52.0"
    }
  }
}

# #################
# S3 Storage Bucket
# #################
locals {
  s3_bucket_name = lower("${var.transfer_server_s3_bucket_name}-${random_id.aws_s3_bucket_transfer_server.hex}")
}

resource "random_id" "aws_s3_bucket_transfer_server" {
  byte_length = 8
}

resource "aws_kms_key" "transfer_server_bucket_key" {
  description             = "This key is used to encrypt the transfer server S3 bucket contents"
  deletion_window_in_days = 10
}


resource "aws_s3_bucket" "transfer_server_bucket" {
  bucket        = local.s3_bucket_name
  acl           = "private"
  force_destroy = false

  versioning {
    enabled = true
  }

  tags = {
    Name = local.s3_bucket_name
  }
}

resource "aws_transfer_server" "transfer_server" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.transfer_server_role.arn
  protocols              = ["SFTP"]
  tags = {
    type = "Managed by Terraform"
  }
}

resource "aws_transfer_ssh_key" "transfer_server_readonly_ssh_keys" {
  count = length(var.transfer_server_readonly_users)

  server_id = aws_transfer_server.transfer_server.id
  user_name = element(aws_transfer_user.transfer_server_readonly_user.*.user_name, count.index)
  body      = var.transfer_server_readonly_users[count.index].ssh_key
}

resource "aws_transfer_ssh_key" "transfer_server_write_ssh_keys" {
  count = length(var.transfer_server_write_users)

  server_id = aws_transfer_server.transfer_server.id
  user_name = element(aws_transfer_user.transfer_server_write_user.*.user_name, count.index)
  body      = var.transfer_server_write_users[count.index].ssh_key
}

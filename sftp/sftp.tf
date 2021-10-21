terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  alias = "source"
  region = var.aws_region
  assume_role {
    role_arn = var.sftp_account_assume_role
  }
}

provider "aws" {
  alias = "target"
  region = var.aws_region
  assume_role {
    role_arn = var.target_storage_assume_role
  }
}

# #################
# S3 Storage Bucket
# #################
locals {
  s3_bucket_name = lower("${var.transfer_server_s3_bucket_name}-${random_id.aws_s3_bucket_transfer_server.hex}")
  s3_target_bucket = lower("${var.transfer_server_s3_bucket_name}-target-${random_id.aws_s3_bucket_transfer_server.hex}")
}

resource "random_id" "aws_s3_bucket_transfer_server" {
  byte_length = 8
}

resource "aws_s3_bucket" "transfer_server_bucket" {
  provider      = aws.source
  bucket        = local.s3_bucket_name
  acl           = "private"
  force_destroy = false

  replication_configuration {
    role = aws_iam_role.replication.arn

    rules {
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.target_storage_bucket.arn
        storage_class = var.transfer_server_target_bucket_storage_class
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = {
    Terraform = true
  }
}

# Public access block settings for Transfer Server backing bucket
resource "aws_s3_bucket_public_access_block" "transfer_server_bucket_block" {
  provider = aws.source
  bucket = aws_s3_bucket.transfer_server_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket" "target_storage_bucket" {
  provider = aws.target
  bucket = local.s3_target_bucket
  acl = "private"
  force_destroy = false

  versioning {
    enabled = true
  }
}

# Public access block settings for target storage bucket
resource "aws_s3_bucket_public_access_block" "target_storage_bucket_block" {
  provider = aws.target
  bucket = aws_s3_bucket.target_storage_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_transfer_server" "transfer_server" {
  count                  = var.transfer_endpoint_type == "PUBLIC" ? 1 : 0
  provider = aws.source
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.transfer_server_role.arn
  protocols              = ["SFTP"]
  endpoint_type          = var.transfer_endpoint_type
  tags = {
    Terrafrom = true
  }
}

resource "aws_transfer_server" "transfer_server_private" {
  count                  = var.transfer_endpoint_type == "VPC" ? 1 : 0
  provider               = aws.source
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.transfer_server_role.arn
  protocols              = ["SFTP"]
  endpoint_type          = var.transfer_endpoint_type
  endpoint_details {
    subnet_ids = var.transfer_server_subnet_ids
    vpc_id     = var.transfer_server_vpc_id
    vpc_endpoint_id = ""
  }

  tags = {
    Terraform = true
  }
}

## PUBLIC SERVER
resource "aws_transfer_ssh_key" "transfer_server_readonly_ssh_keys_public" {
  provider  = aws.source
  count     = var.transfer_endpoint_type == "PUBLIC" ? length(var.transfer_server_readonly_users) : 0
  server_id = aws_transfer_server.transfer_server[0].id
  user_name = element(aws_transfer_user.transfer_server_readonly_user_public.*.user_name, count.index)
  body      = var.transfer_server_readonly_users[count.index].ssh_key
}

resource "aws_transfer_ssh_key" "transfer_server_write_ssh_keys_public" {
  provider = aws.source
  count = var.transfer_endpoint_type == "PUBLIC" ? length(var.transfer_server_write_users) : 0

  server_id = aws_transfer_server.transfer_server[0].id
  user_name = element(aws_transfer_user.transfer_server_write_user_public.*.user_name, count.index)
  body      = var.transfer_server_write_users[count.index].ssh_key
}

## PRIVATE SERVER
resource "aws_transfer_ssh_key" "transfer_server_readonly_ssh_keys_private" {
  provider  = aws.source
  count     = var.transfer_endpoint_type == "VPC" ? length(var.transfer_server_readonly_users) : 0
  server_id = aws_transfer_server.transfer_server_private[0].id
  user_name = element(aws_transfer_user.transfer_server_readonly_user_private.*.user_name, count.index)
  body      = var.transfer_server_readonly_users[count.index].ssh_key
}

resource "aws_transfer_ssh_key" "transfer_server_write_ssh_keys_private" {
  provider  = aws.source
  count     = var.transfer_endpoint_type == "VPC" ? length(var.transfer_server_write_users) : 0
  server_id = aws_transfer_server.transfer_server_private[0].id
  user_name = element(aws_transfer_user.transfer_server_write_user_private.*.user_name, count.index)
  body      = var.transfer_server_write_users[count.index].ssh_key
}

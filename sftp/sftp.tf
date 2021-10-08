terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.52.0"
    }
  }
}

provider "aws" {
  alias = "ephemeral"
  region = var.aws_region
  assume_role {
    role_arn = var.sftp_account_assume_role
  }
}

provider "aws" {
  alias = "permanent"
  region = var.aws_region
  assume_role {
    role_arn = var.permanent_storage_assume_role
  }
}

# #################
# S3 Storage Bucket
# #################
locals {
  s3_bucket_name = lower("${var.transfer_server_s3_bucket_name}-${random_id.aws_s3_bucket_transfer_server.hex}")
  s3_permanent_bucket = lower("${var.transfer_server_s3_bucket_name}-permanent-${random_id.aws_s3_bucket_transfer_server.hex}")
}

resource "random_id" "aws_s3_bucket_transfer_server" {
  byte_length = 8
}

resource "aws_s3_bucket" "transfer_server_bucket" {
  provider      = aws.ephemeral
  bucket        = local.s3_bucket_name
  acl           = "private"
  force_destroy = false

  replication_configuration {
    role = aws_iam_role.replication.arn

    rules {
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.permanent_storage.arn
        storage_class = var.transfer_server_permanent_bucket_storage_class
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = {
    type = "Managed by Terraform"
  }
}

resource "aws_s3_bucket" "permanent_storage" {
  provider = aws.permanent
  bucket = local.s3_permanent_bucket
  acl = "private"
  force_destroy = false

  versioning {
    enabled = true
  }
}


resource "aws_transfer_server" "transfer_server" {
  count                  = var.transfer_endpoint_type == "PUBLIC" ? 1 : 0
  provider = aws.ephemeral
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.transfer_server_role.arn
  protocols              = ["SFTP"]
  endpoint_type          = var.transfer_endpoint_type
  tags = {
    type = "Managed by Terraform"
  }
}

resource "aws_transfer_server" "transfer_server_private" {
  count                  = var.transfer_endpoint_type == "VPC" ? 1 : 0
  provider               = aws.ephemeral
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
    type = "Managed by Terraform"
  }
}

## PUBLIC SERVER
resource "aws_transfer_ssh_key" "transfer_server_readonly_ssh_keys_public" {
  provider  = aws.ephemeral
  count     = var.transfer_endpoint_type == "PUBLIC" ? length(var.transfer_server_readonly_users) : 0
  server_id = aws_transfer_server.transfer_server[0].id
  user_name = element(aws_transfer_user.transfer_server_readonly_user_public.*.user_name, count.index)
  body      = var.transfer_server_readonly_users[count.index].ssh_key
}

resource "aws_transfer_ssh_key" "transfer_server_write_ssh_keys_public" {
  provider = aws.ephemeral
  count = var.transfer_endpoint_type == "PUBLIC" ? length(var.transfer_server_write_users) : 0

  server_id = aws_transfer_server.transfer_server[0].id
  user_name = element(aws_transfer_user.transfer_server_write_user_public.*.user_name, count.index)
  body      = var.transfer_server_write_users[count.index].ssh_key
}

## PRIVATE SERVER
resource "aws_transfer_ssh_key" "transfer_server_readonly_ssh_keys_private" {
  provider  = aws.ephemeral
  count     = var.transfer_endpoint_type == "VPC" ? length(var.transfer_server_readonly_users) : 0
  server_id = aws_transfer_server.transfer_server_private[0].id
  user_name = element(aws_transfer_user.transfer_server_readonly_user_private.*.user_name, count.index)
  body      = var.transfer_server_readonly_users[count.index].ssh_key
}

resource "aws_transfer_ssh_key" "transfer_server_write_ssh_keys_private" {
  provider  = aws.ephemeral
  count     = var.transfer_endpoint_type == "VPC" ? length(var.transfer_server_write_users) : 0
  server_id = aws_transfer_server.transfer_server_private[0].id
  user_name = element(aws_transfer_user.transfer_server_write_user_private.*.user_name, count.index)
  body      = var.transfer_server_write_users[count.index].ssh_key
}

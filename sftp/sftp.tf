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
  bucket = local.s3_bucket_name
  acl = "private"
  force_destroy = false

  tags = {
    Name = local.s3_bucket_name
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.transfer_server_bucket_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "transfer_server_access_block" {
  bucket = aws_s3_bucket.transfer_server_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}



# ############terra
# IAM Policies
# ############
data "aws_iam_policy_document" "transfer_server_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

# ###############
# Policy for transfer server users with write access
# ###############

data "aws_iam_policy_document" "transfer_server_assume_write_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.transfer_server_bucket.arn,
      "${aws_s3_bucket.transfer_server_bucket.arn}/*"
    ]
  }
}

# ############
# Policy for transfer server users with read-only access
# ############

data "aws_iam_policy_document" "transfer_server_to_cloudwatch_assume_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "transfer_server_role" {
  name               = "${var.transfer_server_name}-transfer_server_role"
  assume_role_policy = data.aws_iam_policy_document.transfer_server_assume_role.json
}

resource "aws_iam_role_policy" "transfer_server_policy" {
  name   = "${var.transfer_server_name}-transfer_server_policy"
  role   = aws_iam_role.transfer_server_role.name
  policy = data.aws_iam_policy_document.transfer_server_assume_policy.json
}

resource "aws_iam_role_policy" "transfer_server_to_cloudwatch_policy" {
  name   = "${var.transfer_server_name}-transfer_server_to_cloudwatch_policy"
  role   = aws_iam_role.transfer_server_role.name
  policy = data.aws_iam_policy_document.transfer_server_to_cloudwatch_assume_policy.json
}


resource "aws_transfer_server" "transfer_server" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role = aws_iam_role.transfer_server_role.arn
  protocols = [ "SFTP" ]
  tags = {
    type = "Managed by Terraform"
  }
}

resource "aws_transfer_user" "transfer_server_user" {
  count = length(var.transfer_server_users)

  server_id = aws_transfer_server.transfer_server.id
  user_name =var.transfer_server_users[count.index].user_name
  role = aws_iam_role.transfer_server_role.arn
  home_directory = "/${aws_s3_bucket.transfer_server_bucket.id}/${var.transfer_server_users[count.index].home_directory}"
  restrict_to_homedir = var.transfer_server_users[count.index].restrict_to_homedir
}

resource "aws_transfer_ssh_key" "transfer_server_ssh_key" {
  count = length(var.transfer_server_users)

  server_id = aws_transfer_server.transfer_server.id
  user_name = element(aws_transfer_user.transfer_server_user.*.user_name, count.index)
  body = var.transfer_server_users[count.index].ssh_key
}

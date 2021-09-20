# ############
# IAM Policies
# ############

# Assume Role
data "aws_iam_policy_document" "transfer_server_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

# Transfer server role
resource "aws_iam_role" "transfer_server_role" {
  name               = "${var.transfer_server_name}-transfer_server_role"
  assume_role_policy = data.aws_iam_policy_document.transfer_server_assume_role.json
}

# Policy for Users with write access
data "aws_iam_policy_document" "transfer_server_write_policy_document" {
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

# Role for Users with write access
resource "aws_iam_role" "transfer_server_write_role" {
  name               = "${var.transfer_server_name}-write-role"
  assume_role_policy = data.aws_iam_policy_document.transfer_server_assume_role.json
}

# Policy for Users with read-only access
data "aws_iam_policy_document" "transfer_server_readonly_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.transfer_server_bucket.arn,
      "${aws_s3_bucket.transfer_server_bucket.arn}/*"
    ]
  }
}

# Role for Users with readonly access
resource "aws_iam_role" "transfer_server_readonly_role" {
  name               = "${var.transfer_server_name}-readonly-role"
  assume_role_policy = data.aws_iam_policy_document.transfer_server_assume_role.json
}

# Map write policy to write enabled Users
resource "aws_iam_role_policy" "transfer_server_write_policy" {
  name   = "${var.transfer_server_name}-transfer_server_write_policy"
  role   = aws_iam_role.transfer_server_write_role.name
  policy = data.aws_iam_policy_document.transfer_server_write_policy_document.json
}

resource "aws_iam_role_policy" "transfer_server_readonly_policy" {
  name   = "${var.transfer_server_name}-transfer_server_readonly_policy"
  role   = aws_iam_role.transfer_server_readonly_role.name
  policy = data.aws_iam_policy_document.transfer_server_readonly_policy_document.json
}

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

resource "aws_iam_role_policy" "transfer_server_to_cloudwatch_policy" {
  name   = "${var.transfer_server_name}-transfer_server_to_cloudwatch_policy"
  role   = aws_iam_role.transfer_server_role.name
  policy = data.aws_iam_policy_document.transfer_server_to_cloudwatch_assume_policy.json
}

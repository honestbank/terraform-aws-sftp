# ############
# IAM Policies
# ############

# Assume Role
data "aws_iam_policy_document" "transfer_server_assume_role" {
  provider      = aws.ephemeral
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
  provider      = aws.ephemeral
  name               = "${var.transfer_server_name}-transfer_server_role"
  assume_role_policy = data.aws_iam_policy_document.transfer_server_assume_role.json
}

# Policy for Users with write access
data "aws_iam_policy_document" "transfer_server_write_policy_document" {
  provider      = aws.ephemeral
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
  provider      = aws.ephemeral
  name               = "${var.transfer_server_name}-write-role"
  assume_role_policy = data.aws_iam_policy_document.transfer_server_assume_role.json
}

# Policy for Users with read-only access
data "aws_iam_policy_document" "transfer_server_readonly_policy_document" {
  provider      = aws.ephemeral
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
  provider      = aws.ephemeral
  name               = "${var.transfer_server_name}-readonly-role"
  assume_role_policy = data.aws_iam_policy_document.transfer_server_assume_role.json
}

# Map write policy to write enabled Users
resource "aws_iam_role_policy" "transfer_server_write_policy" {
  provider      = aws.ephemeral
  name   = "${var.transfer_server_name}-transfer_server_write_policy"
  role   = aws_iam_role.transfer_server_write_role.name
  policy = data.aws_iam_policy_document.transfer_server_write_policy_document.json
}

resource "aws_iam_role_policy" "transfer_server_readonly_policy" {
  provider      = aws.ephemeral
  name   = "${var.transfer_server_name}-transfer_server_readonly_policy"
  role   = aws_iam_role.transfer_server_readonly_role.name
  policy = data.aws_iam_policy_document.transfer_server_readonly_policy_document.json
}

data "aws_iam_policy_document" "transfer_server_to_cloudwatch_assume_policy" {
  provider      = aws.ephemeral
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
  provider      = aws.ephemeral
  name   = "${var.transfer_server_name}-transfer_server_to_cloudwatch_policy"
  role   = aws_iam_role.transfer_server_role.name
  policy = data.aws_iam_policy_document.transfer_server_to_cloudwatch_assume_policy.json
}

# Replication policy for S3 to S3 replication
resource "aws_iam_role" "replication" {
  provider      = aws.ephemeral
  name = "sftp-replication-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  provider      = aws.ephemeral
  name = "sftp-replication-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.transfer_server_bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
         "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.transfer_server_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.permanent_storage.arn}/*"
    }
  ]
}
POLICY
}

## PUBLIC SERVER
resource "aws_transfer_user" "transfer_server_readonly_user_public" {
  provider      = aws.ephemeral
  count = var.transfer_endpoint_type == "PUBLIC" ? length(var.transfer_server_readonly_users) : 0

  server_id           = aws_transfer_server.transfer_server[0].id
  user_name           = var.transfer_server_readonly_users[count.index].user_name
  role                = aws_iam_role.transfer_server_readonly_role.arn
  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${aws_s3_bucket.transfer_server_bucket.id}/${var.transfer_server_readonly_users[count.index].home_directory}"
  }
}

resource "aws_transfer_user" "transfer_server_write_user_public" {
  provider      = aws.ephemeral
  count = var.transfer_endpoint_type == "PUBLIC" ? length(var.transfer_server_write_users) : 0

  server_id           = aws_transfer_server.transfer_server[0].id
  user_name           = var.transfer_server_write_users[count.index].user_name
  role                = aws_iam_role.transfer_server_write_role.arn
  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${aws_s3_bucket.transfer_server_bucket.id}/${var.transfer_server_write_users[count.index].home_directory}"
  }
}

## PRIVATE SERVER
resource "aws_transfer_user" "transfer_server_readonly_user_private" {
  provider      = aws.ephemeral
  count = var.transfer_endpoint_type == "VPC" ? length(var.transfer_server_readonly_users) : 0

  server_id           = aws_transfer_server.transfer_server_private[0].id
  user_name           = var.transfer_server_readonly_users[count.index].user_name
  role                = aws_iam_role.transfer_server_readonly_role.arn
  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${aws_s3_bucket.transfer_server_bucket.id}/${var.transfer_server_readonly_users[count.index].home_directory}"
  }
}

resource "aws_transfer_user" "transfer_server_write_user_private" {
  provider      = aws.ephemeral
  count = var.transfer_endpoint_type == "VPC" ? length(var.transfer_server_write_users) : 0

  server_id           = aws_transfer_server.transfer_server_private[0].id
  user_name           = var.transfer_server_write_users[count.index].user_name
  role                = aws_iam_role.transfer_server_write_role.arn
  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${aws_s3_bucket.transfer_server_bucket.id}/${var.transfer_server_write_users[count.index].home_directory}"
  }
}

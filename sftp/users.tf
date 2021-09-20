resource "aws_transfer_user" "transfer_server_readonly_user" {
  count = length(var.transfer_server_readonly_users)

  server_id           = aws_transfer_server.transfer_server.id
  user_name           = var.transfer_server_readonly_users[count.index].user_name
  role                = aws_iam_role.transfer_server_readonly_role.arn
  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${aws_s3_bucket.transfer_server_bucket.id}/${var.transfer_server_readonly_users[count.index].home_directory}"
  }
}

resource "aws_transfer_user" "transfer_server_write_user" {
  count = length(var.transfer_server_write_users)

  server_id           = aws_transfer_server.transfer_server.id
  user_name           = var.transfer_server_write_users[count.index].user_name
  role                = aws_iam_role.transfer_server_write_role.arn
  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${aws_s3_bucket.transfer_server_bucket.id}/${var.transfer_server_write_users[count.index].home_directory}"
  }
}

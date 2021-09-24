output "transfer_server_arn" {
  value = var.transfer_endpoint_type == "PUBLIC" ? aws_transfer_server.transfer_server[0].arn : aws_transfer_server.transfer_server_private[0].arn
}

output "transfer_server_id" {
  value = var.transfer_endpoint_type == "PUBLIC" ? aws_transfer_server.transfer_server[0].id : aws_transfer_server.transfer_server_private[0].id
}

output "transfer_server_endpoint" {
  value = var.transfer_endpoint_type == "PUBLIC" ? aws_transfer_server.transfer_server[0].endpoint : aws_transfer_server.transfer_server_private[0].endpoint
}

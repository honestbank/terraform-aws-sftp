output "transfer_server_arn" {
  description =  "The Amazon Resource Name (ARN) of the transfer server"
  value = var.transfer_endpoint_type == "PUBLIC" ? aws_transfer_server.transfer_server[0].arn : aws_transfer_server.transfer_server_private[0].arn
}

output "transfer_server_id" {
  description =  "The terraform ID of the transfer server"
  value = var.transfer_endpoint_type == "PUBLIC" ? aws_transfer_server.transfer_server[0].id : aws_transfer_server.transfer_server_private[0].id
}

output "transfer_server_endpoint" {
  description =  "The endpoint (URI) of the transfer server"
  value = var.transfer_endpoint_type == "PUBLIC" ? aws_transfer_server.transfer_server[0].endpoint : aws_transfer_server.transfer_server_private[0].endpoint
}

output "transfer_storage_bucket_name" {
  description =  "The bucket name of transfer storage"
  value = aws_s3_bucket.transfer_server_bucket.id
}

output "transfer_storage_bucket_arn" {
  description =  "The bucket ARN of target storage"
  value = aws_s3_bucket.transfer_server_bucket.arn
}

output "target_storage_bucket_name" {
  description =  "The bucket name of target storage"
  value = aws_s3_bucket.target_storage_bucket.id
}

output "target_storage_bucket_arn" {
  description =  "The bucket ARN of target storage"
  value = aws_s3_bucket.target_storage_bucket.arn
}

variable "aws_region" {
  type        = string
  description = "The AWS Region in which to provision the managed SFTP service + S3 buckets"
}

variable "transfer_server_name" {
  type        = string
  description = "The name to apply to the transfer server i.e: Example's SFTP server"
}

variable "transfer_endpoint_type" {
  type        = string
  description = "Used to set the SFTP server to a public or private (inside VPC) deployment"
}

variable "transfer_server_s3_bucket_name" {
  type        = string
  description = "The name to apply to the transfer server's s3 storage bucket"
}

variable "transfer_server_target_bucket_storage_class" {
  type = string
  description = "The S3 storage class to create the bucket in. Defaults to STANDARD"
  default = "STANDARD"
}

variable "transfer_server_readonly_users" {
  type        = list(any)
  description = "list of user objects for users with readonly access"
  default     = []
}

variable "transfer_server_subnet_ids" {
  type    = list(any)
  default = []
}

variable "transfer_server_write_users" {
  type        = list(any)
  description = "list of user objects for users with write access"
  default     = []
}

variable "transfer_server_vpc_id" {
  type    = string
  description = "The Id of the transfer server's VPC"
}

variable "sftp_account_assume_role" {
  description = "The ARN of the role to assume to install the SFTP server"
  type = string
}

variable "target_storage_assume_role" {
  description = "The ARN of the role to assume"
  type = string
}

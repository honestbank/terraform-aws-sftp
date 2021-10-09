variable "aws_region" {
  type        = string
  description = "The AWS Region in which to provision the managed SFTP service + S3 buckets"
}

variable "transfer_endpoint_type" {
  type        = string
  description = "Used to set the SFTP server to a public or private (inside VPC) deployment"
  default     = "PUBLIC"
}

variable "transfer_endpoint_details" {
  type    = list(any)
  default = []
}

variable "transfer_server_name" {
  type        = string
  description = "The name to apply to the transfer server i.e: Example's SFTP server"
}

variable "transfer_server_s3_bucket_name" {
  type        = string
  description = "The name to apply to the transfer server's s3 storage bucket"
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
  type        = string
  description = "The Id of the VPC that willhouse the transfer server"
}

variable "sftp_account_assume_role" {
  description = "The ARN of the role to assume to install the SFTP server"
  type        = string
}

variable "target_storage_assume_role" {
  description = "The ARN of the role to assume"
  type        = string
}

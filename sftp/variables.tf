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

variable "transfer_server_write_users" {
  type        = list(any)
  description = "list of user objects for users with write access"
  default     = []
}

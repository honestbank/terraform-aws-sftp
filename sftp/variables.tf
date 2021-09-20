variable "transfer_server_name" {
  type = string
  description = "The name to apply to the transfer server i.e: Example's SFTP server"
}

variable "transfer_server_s3_bucket_name" {
  type = string
  description = "The name to apply to the transfer server's s3 storage bucket"
}

variable "transfer_server_users" {
  type = list
  description = "list of server user objects"
  default = [
    {
      username = "example_user_1"
      ssh_key = "ssh-rsa EXAMPLEKEY"
    }
  ]
}

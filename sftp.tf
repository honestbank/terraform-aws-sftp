provider "aws" {
  region = var.aws_region
}

provider "aws" {
  region = var.aws_region
  alias  = "source"
  assume_role {
    role_arn = var.source_role_arn
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "target"
  assume_role {
    role_arn = var.target_role_arn
  }
}

module "sftp" {
  source                                      = "./sftp"
  aws_region                                  = var.aws_region
  target_storage_assume_role                  = var.target_storage_assume_role
  sftp_account_assume_role                    = var.sftp_account_assume_role
  transfer_endpoint_type                      = var.transfer_endpoint_type
  transfer_server_name                        = var.transfer_server_name
  transfer_server_s3_bucket_name              = var.transfer_server_s3_bucket_name
  transfer_server_target_bucket_storage_class = "STANDARD"
  transfer_server_subnet_ids                  = []
  transfer_server_vpc_id                      = var.transfer_server_vpc_id
  transfer_server_write_users                 = var.transfer_server_write_users
  transfer_server_readonly_users              = var.transfer_server_readonly_users
}

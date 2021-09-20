terraform {
  backend "remote" {
    organization = "honestbank"

    workspaces {
      name = "terraform-aws-sftp"
    }
  }
  required_version = "~> 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.52.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "sftp" {
  source                         = "./sftp"
  transfer_server_name           = var.transfer_server_name
  transfer_server_s3_bucket_name = var.transfer_server_s3_bucket_name
  transfer_server_users          = var.transfer_server_users
}

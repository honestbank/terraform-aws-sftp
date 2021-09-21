# Terraform AWS SFTP

This script builds an AWS Transfer Family server that is backed by an S3 bucket:

    * Communicates via SFTP (ftp, ftps are disabled)
    * Users access the SFTP server via SSH keys
    * Provides readonly and write users
    * Users are locked to their home directory and sub-directories
    * SFTP activity logged to Cloudwatch

## Requirements

| Name                                                                      | Version   |
| ------------------------------------------------------------------------- | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0.0  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | ~> 3.52.0 |

## Providers

| Name                                              | Version |
| ------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.52.0  |

## Inputs

| Name                                                                                                                              | Description                                                        | Type  | Default | Required |
| --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----- | ------- | :------: |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region)                                                                | AWS region to install the Transfer Server (SFTP server) into       | `any` | n/a     |   yes    |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region)                                                                | AWS region to install the Transfer Server (SFTP server) into       | `any` | n/a     |   yes    |
| <a name="input_transfer_server_name"></a> [transfer\_server\_name](#input\_transfer\_server\_name)                                | The name to be given the the transfer server                       | `any` | n/a     |   yes    |
| <a name="input_transfer_s3_bucket_name"></a> [transfer\_server\_s3\_bucket\_name](#input\_transfer\_server\_s3\_bucket\_name)     | The name of the S3 bucket supplying storage to the transfer server | `any` | n/a     |   yes    |
| <a name="input_transfer_server_write_users"></a> [transfer\_server\_write_users](#input\_transfer\_server\_write\_users)          | A list of users with write access in the format listed below       | `any` | n/a     |   yes    |
| <a name="input_transfer_server_readonly_users"></a> [transfer\_server\_readonly_users](#input\_transfer\_server\_readonly\_users) | A list of users with readonly access in the format listed below    | `any` | n/a     |   yes    |


### Example of transfer_server_write_users and terraform_server_readonly_users:
```
transfer_server_write_users = [
    {
    user_name      = "example1-user"
    ssh_key        = "<public SSH key for example1-user>"
    home_directory = "<home directory for example-1 user>"
    },
    {
    user_name      = "example2-user"
    ssh_key        = "<public SSH key for example2-user>"
    home_directory = "<home directory for example-2 user>"
    }
]

transfer_server_readonly_users = [
    {
    user_name      = "example1-readonly-user"
    ssh_key        = "<public SSH key for example1-readonly-user>"
    home_directory = "<home directory for example-readonly-1 user>"
    },
    {
    user_name      = "example2-readonly-user"
    ssh_key        = "<public SSH key for example2-readonly-user>"
    home_directory = "<home directory for example-readonly-2 user>"
    }
]
```

## Outputs

| Name                                                                                                                                    | Description                                      |
| --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| <a name="transfer_server_arn"><a> [transfer\_server\_arn](#transfer\_server\_arn) The Amazon Resource Name (ARN) of the transfer server |
| <a name="transfer_server_id"></a> [transfer\_server\_id](#transfer\_server\_id)                                                         | The Terraform id of the transfer server resource |
| <a name="transfer_server_endpoint"></a> [transfer\_server\_endpoint](#transfer\_server\_endpoint)                                       | The endpoint (URI) of the transfer server        |

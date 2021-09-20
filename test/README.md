# terraform-aws-eks Tests

This module is tested using the [Terratest framework](https://github.com/gruntwork-io/terratest).

## Running Tests

1. Assume the `OrganizationAccountAccessRole` role in the AWS account we use for tests:

```shell
output=$(aws sts assume-role --role-arn arn:aws:iam::106256755710:role/OrganizationAccountAccessRole --role-session-name lab-role-session)
export AWS_ACCESS_KEY_ID=$(echo $output | jq -r '.Credentials.AccessKeyId') \
       AWS_SECRET_ACCESS_KEY=$(echo $output | jq -r '.Credentials.SecretAccessKey') \
       AWS_SESSION_TOKEN=$(echo $output | jq -r '.Credentials.SessionToken') \
	   AWS_DEFAULT_REGION="ap-southeast-1"
```

2. Run tests:

```shell
$ go test -v -timeout 30m
```

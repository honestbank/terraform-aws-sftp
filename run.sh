# Test credentials to build the EKS cluster in our lab environment
# 

export AWS_ACCESS_KEY_ID="<AWS ACCESS KEY>"
export AWS_SECRET_ACCESS_KEY="<AWS SECRET ACCESS KEY>"
export AWS_DEFAULT_REGION="<REGION>"

terraform apply -var-file=test.tfvars
terraform destroy -var-file=test.tfvars

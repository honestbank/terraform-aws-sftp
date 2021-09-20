package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTerraformAwsTransfer(t *testing.T) {
	t.Parallel()

	name := fmt.Sprintf("labs-sftp-terratest-%s", random.UniqueId())

	workingDir := test_structure.CopyTerraformFolderToTemp(t, "../sftp", ".")
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"transfer_server_name":           "terratest-sftp-server",
			"transfer_server_s3_bucket_name": name,
			"transfer_server_users": []map[string]interface{}{
				{
					"user_name":      "example1-user",
					"ssh_key":        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOt6TLtVqAZ2cb07xmmatfDbThVu3lEP8i0wnhZ0/t11YRARvoLQf31LaxI20M6oSRJNLpuSyl2jDJ35/BpltdAsSC7eGumxSev23dr5l3MSKNEnZzrAbBPtKpQKALqsXuG9d6Xf9N4pMTn0LjswCKcnHAiO+DoqoX8NS2sT7znOzA6/IxXiYUsNsOiI2pyM9Z6z+m+ukOvZyjuF5bdLMjyTwCtlCOZ1XpD4c+bu/uJsWECKp14hn23QJtGo/KebpY4oUn/qYo1WC+0wVp2AQsDeNcojiTsU9fBADM0SzVp5OR0r2tbBgxXrB2adApj+YpBtaOTDt3E2j32otsYGTF0snf974eLsumZ5TI3aaVKH1NgqhTjRyifmI4h65/h3qVlggNV3ywAzSHtn79FEEXaJDiOFLRSsMTpaUkM5CjiJR5/PxkJ7LxPMECzET+juSosWfrc2Ttivke9HhIi6FJBnNIOnuvUHU/EEWA55vnqlVnZMoCVPPJd0BvbTACXtM=",
					"home_directory": "example1-home",
				},
				{
					"user_name":      "example2-user",
					"ssh_key":        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOt6TLtVqAZ2cb07xmmatfDbThVu3lEP8i0wnhZ0/t11YRARvoLQf31LaxI20M6oSRJNLpuSyl2jDJ35/BpltdAsSC7eGumxSev23dr5l3MSKNEnZzrAbBPtKpQKALqsXuG9d6Xf9N4pMTn0LjswCKcnHAiO+DoqoX8NS2sT7znOzA6/IxXiYUsNsOiI2pyM9Z6z+m+ukOvZyjuF5bdLMjyTwCtlCOZ1XpD4c+bu/uJsWECKp14hn23QJtGo/KebpY4oUn/qYo1WC+0wVp2AQsDeNcojiTsU9fBADM0SzVp5OR0r2tbBgxXrB2adApj+YpBtaOTDt3E2j32otsYGTF0snf974eLsumZ5TI3aaVKH1NgqhTjRyifmI4h65/h3qVlggNV3ywAzSHtn79FEEXaJDiOFLRSsMTpaUkM5CjiJR5/PxkJ7LxPMECzET+juSosWfrc2Ttivke9HhIi6FJBnNIOnuvUHU/EEWA55vnqlVnZMoCVPPJd0BvbTACXtM=",
					"home_directory": "example2-home",
				},
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "ap-southeast-1",
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	transfer_endpoint := terraform.Output(t, terraformOptions, "transfer_server_endpoint")

	// Verify we're getting back the outputs we expect
	// Ensure we get a random number appended
	expectedTransferEndpoint := "server.transfer.ap-southeast-1.amazonaws.com"
	assert.True(t,
		strings.HasSuffix(transfer_endpoint, expectedTransferEndpoint),
		fmt.Sprintf("Transfer endpoint should end with %v", expectedTransferEndpoint))
}

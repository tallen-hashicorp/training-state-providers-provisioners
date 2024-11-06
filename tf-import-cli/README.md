# Import Resources
You may need to import existing resource configuration into Terraform state

Terraform CLI has commands to assist with this:

```bash
terraform show -json
terraform import aws_s3_bucket.example tallen-test-import
terraform show -no-color > compute.tf
```
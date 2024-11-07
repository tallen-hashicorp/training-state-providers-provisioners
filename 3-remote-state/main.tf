# Terraform configuration
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "~> 2.2"
    }
  }
  
  backend "s3" {
    bucket = "tough-mole-terraform-state-bucket"    # Replace this with the output bucket_name from the previous example
    key    = "example/terraform.tfstate"            # Path to store the state file within the bucket
    region = "us-west-2"                            # Replace with your AWS region
  }
}

# Provider for local resources
provider "local" {}

# Resource to create a local file
resource "local_file" "example" {
  filename = "${path.module}/example.txt"
  content  = "Hello, Terraform with remote state!"
}
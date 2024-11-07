# Terraform configuration
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "~> 2.2"
    }
  }
}

# Provider for local resources
provider "local" {}

# Resource to create a local file
resource "local_file" "example" {
  filename = "${path.module}/example.txt"
  content  = "Hello, Terraform!"
}

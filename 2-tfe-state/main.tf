# Terraform configuration
terraform {
  cloud { 
    organization = "tallen-demo" 
    workspaces { 
      name = "cli-demo" 
    } 
  }
}

# Configure the AWS provider
provider "aws" {
  region = "us-west-2"  # Replace with your preferred region
}

# Generate a random name for the S3 bucket
resource "random_pet" "bucket_name" {
  length    = 2
  separator = "-"
}

# Create an S3 bucket for Terraform state with a random name
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${random_pet.bucket_name.id}-terraform-state-bucket"  # Unique bucket name

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Development"
  }
}

# Output the bucket name
output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
  description = "The unique name of the S3 bucket for Terraform state."
}

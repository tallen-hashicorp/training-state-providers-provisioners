# Configure the AWS provider
provider "aws" {
  region = "us-west-2"  # Replace with your preferred region
}

resource "aws_s3_bucket" "example" {
  bucket = "tallen-massive-test-bucket"  # Unique bucket name
}
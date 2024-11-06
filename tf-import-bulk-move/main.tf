# Configure the AWS provider
provider "aws" {
  region = "us-west-2"  # Replace with your preferred region
}

# Import

# import {
#  to = aws_s3_bucket.example
#  id = "tallen-test-import"
# }

resource "aws_s3_bucket" "example" {
  bucket = "tallen-massive-test-bucket"  # Unique bucket name
}

# Moved

# resource "aws_s3_bucket" "new" {
#   bucket = "tallen-massive-test-bucket"  # Unique bucket name
# }

# moved {
#  from = aws_s3_bucket.example
#  to   = aws_s3_bucket.new
# }

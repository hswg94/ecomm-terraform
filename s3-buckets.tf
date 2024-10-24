# This bucket is used for codepipeline to store artifacts\
resource "aws_s3_bucket" "ecomm-express-api-bucket" {
  bucket = "ecomm-express-api-bucket-for-codepipeline"
}

resource "aws_s3_bucket_public_access_block" "ecomm-express-api-bucket_pab" {
  bucket = aws_s3_bucket.ecomm-express-api-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
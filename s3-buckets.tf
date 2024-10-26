# This bucket is used for codepipeline to store artifacts
resource "aws_s3_bucket" "ecomm-api-bucket" {
  bucket = "ecomm-api-storage-for-codepipeline"
  force_destroy = "true" //allow bucket to be deleted by terraform without removing files
}

resource "aws_s3_bucket_public_access_block" "ecomm-api-bucket_pab" {
  bucket = aws_s3_bucket.ecomm-api-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
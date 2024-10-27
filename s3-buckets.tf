# This bucket is accessed by codepipeline to store ecomm-api
resource "aws_s3_bucket" "ecomm-api-s3-for-cp" {
  bucket = "ecomm-api-s3-for-cp"
  force_destroy = "true" //allow bucket to be deleted by terraform without removing files
}

resource "aws_s3_bucket_public_access_block" "ecomm-api-bucket-pab" {
  bucket = aws_s3_bucket.ecomm-api-s3-for-cp.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

///////////////////////////////////////////////////////

# This bucket is accessed by codepipeline to store ecomm-frontend
resource "aws_s3_bucket" "ecomm-frontend-s3-for-cb-and-cf" {
  bucket = "ecomm-frontend-s3-for-cb-and-cf"
  force_destroy = "true" //allow bucket to be deleted by terraform without removing files
}

resource "aws_s3_bucket_public_access_block" "ecomm-frontend-bucket-pab" {
  bucket = aws_s3_bucket.ecomm-frontend-s3-for-cb-and-cf.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
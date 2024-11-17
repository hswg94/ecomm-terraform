# This bucket is accessed by codepipeline to store ecomm-api
resource "aws_s3_bucket" "ecomm-api-s3-for-cp" {
  bucket        = "ecomm-api-s3-for-cp"
  force_destroy = "true" //allow bucket to be deleted by terraform without removing files
}

resource "aws_s3_bucket_public_access_block" "ecomm-api-bucket-pab" {
  bucket                  = aws_s3_bucket.ecomm-api-s3-for-cp.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

///////////////////////////////////////////////////////

# This bucket is accessed by codepipeline to store ecomm-frontend
resource "aws_s3_bucket" "ecomm-frontend-s3-for-cb-and-cf" {
  bucket        = "ecomm-frontend-s3-for-cb-and-cf"
  force_destroy = "true" //allow bucket to be deleted by terraform without removing files
}

resource "aws_s3_bucket_public_access_block" "ecomm-api-bucket-pab" {
  bucket                  = aws_s3_bucket.ecomm-frontend-s3-for-cb-and-cf
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow-cloudfront-access" {
  bucket = aws_s3_bucket.ecomm-frontend-s3-for-cb-and-cf.id
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::ecomm-frontend-s3-for-cb-and-cf/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : aws_cloudfront_distribution.s3-distribution.arn
          }
        }
      }
    ]
  })
}
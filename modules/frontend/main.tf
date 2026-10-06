////////////////////////////////////////////////////////////////////
// Site Bucket

# This bucket is accessed by codebuild and cloudfront
resource "aws_s3_bucket" "site" {
  bucket        = var.bucket_name
  force_destroy = "true" //allow bucket to be deleted by terraform
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
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
        "Resource" : "${aws_s3_bucket.site.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : aws_cloudfront_distribution.site.arn
          }
        }
      }
    ]
  })
}

////////////////////////////////////////////////////////////////////
// CloudFront

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "oac-for-s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  price_class         = "PriceClass_All"
  aliases             = [var.frontend_domain, "www.${var.frontend_domain}"]
  http_version        = "http2"
  default_root_object = "index.html"
  is_ipv6_enabled     = true

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
    origin_id                = aws_s3_bucket.site.id
  }

  default_cache_behavior {
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.site.id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = [] # ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"     # sni-only for cost-effectiveness
    minimum_protocol_version = "TLSv1.2_2021" # Ensures TLS 1.2+ for modern security compliance
  }

  # In a SPA, index.html handles all entry points and routes for the entire app.
  # If the CDN tries to find a real file at /profile, it will fail and a 403 or 404.
  # The custom error response tells it to serve index.html instead, so the SPA can render the correct view based on the URL.
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
}

////////////////////////////////////////////////////////////////////
// DNS Records

//Create Records for Frontend CloudFront Distribution
resource "aws_route53_record" "frontend" {
  zone_id = var.zone_id
  name    = var.frontend_domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "frontend_www" {
  zone_id = var.zone_id
  name    = "www.${var.frontend_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_route53_record.frontend.name]
}

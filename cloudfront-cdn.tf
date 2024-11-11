resource "aws_cloudfront_origin_access_control" "oac-for-s3" {
  name                              = "oac-for-s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3-distribution" {
  enabled = true
  origin {
    domain_name              = aws_s3_bucket.ecomm-frontend-s3-for-cb-and-cf.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac-for-s3.id
    origin_id                = aws_s3_bucket.ecomm-frontend-s3-for-cb-and-cf.id
  }
  default_cache_behavior {
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.ecomm-frontend-s3-for-cb-and-cf.id

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

  price_class = "PriceClass_All"

  aliases = ["ecomm.hswg94.com"]
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.us-east-1-cert.arn
    ssl_support_method       = "sni-only"     # sni-only for cost-effectiveness
    minimum_protocol_version = "TLSv1.2_2021" # Ensures TLS 1.2+ for modern security compliance
  }
  http_version        = "http2"
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  depends_on = [aws_acm_certificate_validation.us-east-1-cert]
  
  custom_error_response {
    error_caching_min_ttl = 300
    error_code = 403
    response_code = 200
    response_page_path = "/index.html"
  }
}

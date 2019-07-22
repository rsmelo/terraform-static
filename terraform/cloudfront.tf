locals {
  s3_origin_id = "${aws_s3_bucket.site.bucket_regional_domain_name}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${local.s3_origin_id}"
    origin_id = "${local.s3_origin_id}"
  }

  enabled = true
  is_ipv6_enabled = true
  comment = "Managed by terraform"
  default_root_object = "index.html"

  logging_config {
    include_cookies = true
    bucket = "${aws_s3_bucket.log.bucket_regional_domain_name}"
    prefix = "cdn"
  }

  aliases = ["${var.domain}"]

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

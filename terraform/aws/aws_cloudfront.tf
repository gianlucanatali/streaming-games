
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "${local.resource_prefix}__cloudfront_origin_ac"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "games" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "streaming-games"
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.games.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id   = local.s3_origin_id

    
    //origin_access_control_id = aws_cloudfront_origin_access_control.default.id

    /*s3_origin_config {
        origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }*/
  }

  origin {
    domain_name = "${aws_api_gateway_rest_api.event_handler_api.id}.execute-api.${var.aws_region}.amazonaws.com"

    //domain_name =${aws_api_gateway_deployment.event_handler_v1.invoke_url}
    origin_id   = local.api_gw_origin_id
    //origin_path="/${aws_api_gateway_stage.event_handler_v1.stage_name}"
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" #CachingDisabled

    /*forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }*/
    viewer_protocol_policy = "redirect-to-https"
    /*min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400*/
  }

  ordered_cache_behavior {
    path_pattern     = "/${aws_api_gateway_stage.event_handler_v1.stage_name}${aws_api_gateway_resource.event_handler_resource.path}"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.api_gw_origin_id
    //cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized

    cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" #CachingDisabled

    /*min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400*/
    compress               = true
    viewer_protocol_policy = "https-only"
  }


  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      locations = []
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

/*
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "s3-bucket-access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
*/

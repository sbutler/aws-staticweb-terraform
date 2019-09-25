# =========================================================
# Resources
# =========================================================

resource "aws_cloudfront_distribution" "website" {
    count = "${var.cloudfront_enabled ? 1 : 0}"

    enabled = true
    is_ipv6_enabled = true
    comment = "Managed distribution for ${var.project}-website."
    price_class = "PriceClass_100"

    logging_config {
        bucket = "${local.logs_bucket}.s3.amazonaws.com"
        prefix = "${var.cloudfront_logs_prefix}"
    }

    aliases = [ "${var.cloudfront_domains}" ]
    viewer_certificate {
        acm_certificate_arn = "${var.cloudfront_certificate_arn}"
        cloudfront_default_certificate = "${length(var.cloudfront_certificate_arn) == 0 ? 1 : 0}"

        minimum_protocol_version = "TLSv1"
        ssl_support_method = "sni-only"
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    origin {
        origin_id   = "S3Web-${var.project}-web"
        domain_name = "${aws_s3_bucket.website.website_endpoint}"

        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "http-only"
            origin_ssl_protocols = [ "TLSv1.2" ]
        }
    }

    default_cache_behavior {
        target_origin_id = "S3Web-${var.project}-web"
        viewer_protocol_policy = "${length(var.cloudfront_certificate_arn) == 0 ? "allow-all" : "redirect-to-https"}"

        allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
        cached_methods = [ "GET", "HEAD" ]
        min_ttl = "${var.cloudfront_min_ttl}"
        max_ttl = "${var.cloudfront_max_ttl}"
        default_ttl = "${var.cloudfront_default_ttl}"

        forwarded_values {
            cookies {
                forward = "none"
            }

            headers = [
                "Access-Control-Request-Headers",
                "Access-Control-Request-Method",
                "Origin",
            ]
            query_string = false
        }

        smooth_streaming = false
        compress = true
    }

    custom_error_response {
        error_code = 400
        response_code = 400
        response_page_path = "/error/400.html"
    }
    custom_error_response {
        error_code = 403
        response_code = 403
        response_page_path = "/error/403.html"
    }
    custom_error_response {
        error_code = 404
        response_code = 404
        response_page_path = "/error/404.html"
        error_caching_min_ttl = 0
    }
    custom_error_response {
        error_code = 405
        response_code = 405
        response_page_path = "/error/405.html"
    }
    custom_error_response {
        error_code = 414
        response_code = 414
        response_page_path = "/error/414.html"
    }
    custom_error_response {
        error_code = 500
        response_code = 500
        response_page_path = "/error/500.html"
    }
    custom_error_response {
        error_code = 501
        response_code = 501
        response_page_path = "/error/501.html"
    }
    custom_error_response {
        error_code = 502
        response_code = 502
        response_page_path = "/error/502.html"
    }
    custom_error_response {
        error_code = 503
        response_code = 503
        response_page_path = "/error/503.html"
    }
    custom_error_response {
        error_code = 504
        response_code = 504
        response_page_path = "/error/504.html"
    }


    tags {
        Service = "${var.service}"
        Contact = "${var.contact}"
        Environment = "${var.environment}"

        Project = "${var.project}"
    }
}

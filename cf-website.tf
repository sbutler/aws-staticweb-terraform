# =========================================================
# Locals
# =========================================================

locals {
    cf_useragent = var.cloudfront_enabled ? "Amazon CloudFront/${nonsensitive(random_password.cf_useragent_password.result)}" : null
}

# =========================================================
# Resources
# =========================================================

resource "random_password" "cf_useragent_password" {
    length  = 32
    special = false
}

resource "aws_cloudfront_distribution" "website" {
    count = var.cloudfront_enabled ? 1 : 0

    enabled         = true
    is_ipv6_enabled = true
    comment         = "Managed distribution for ${local.name_prefix}website."
    price_class     = "PriceClass_100"

    logging_config {
        bucket = "${module.website.logs_bucket}.s3.amazonaws.com"
        prefix = var.cloudfront_logs_prefix
    }

    aliases = var.cloudfront_domains
    viewer_certificate {
        acm_certificate_arn            = var.cloudfront_certificate_arn
        cloudfront_default_certificate = var.cloudfront_certificate_arn == null ? true : false

        minimum_protocol_version = var.cloudfront_certificate_arn == null ? null : "TLSv1.2_2021"
        ssl_support_method       = "sni-only"
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    origin {
        origin_id   = "S3Web-web"
        domain_name = module.website.website_endpoint

        custom_header {
            name  = "User-Agent"
            value = local.cf_useragent
        }

        custom_origin_config {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "http-only"
            origin_ssl_protocols   = [ "TLSv1.2" ]
        }
    }

    origin {
        origin_id   = "S3Web-web-failover"
        domain_name = module.website_failover[count.index].website_endpoint

        custom_header {
            name  = "User-Agent"
            value = local.cf_useragent
        }

        custom_origin_config {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "http-only"
            origin_ssl_protocols   = [ "TLSv1.2" ]
        }
    }

    origin_group {
        origin_id = "S3Web"

        failover_criteria {
            status_codes = [ 500, 502, 503, 504 ]
        }

        member {
            origin_id = "S3Web-web"
        }

        member {
            origin_id = "S3Web-web-failover"
        }
    }

    default_cache_behavior {
        target_origin_id       = "S3Web"
        viewer_protocol_policy = var.cloudfront_certificate_arn == null ? "allow-all" : "redirect-to-https"

        allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
        cached_methods  = [ "GET", "HEAD" ]
        min_ttl         = var.cloudfront_min_ttl
        max_ttl         = var.cloudfront_max_ttl
        default_ttl     = var.cloudfront_default_ttl

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
        compress         = true
    }

    dynamic "custom_error_response" {
        for_each = local.website_error_codes
        content {
            error_code            = tonumber(custom_error_response.key)
            response_code         = tonumber(custom_error_response.key)
            response_page_path    = "/error/${custom_error_response.key}.html"
            error_caching_min_ttl = custom_error_response.value.min_ttl
        }
    }
}

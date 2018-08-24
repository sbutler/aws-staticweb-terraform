# =========================================================
# Locals
# =========================================================

locals {
    cloudfront_website_oai_path = "${
        length(var.cloudfront_origin_access_identity_path) == 0
        ? join("", aws_cloudfront_origin_access_identity.website.*.cloudfront_access_identity_path)
        : var.cloudfront_origin_access_identity_path
    }"
    cloudfront_website_oai_iam_arn = "${
        length(var.cloudfront_origin_access_identity_path) == 0
        ? join("", aws_cloudfront_origin_access_identity.website.*.iam_arn)
        : var.cloudfront_origin_access_identity_iam_arn
    }"
}


# =========================================================
# Resources
# =========================================================

resource "aws_cloudfront_origin_access_identity" "website" {
    count = "${length(var.cloudfront_origin_access_identity_path) == 0 ? 1 : 0}"

    comment = "Managed identity for ${var.project}-website."
}

resource "aws_cloudfront_distribution" "website" {
    count = "${length(var.cloudfront_origin_access_identity_path) == 0 ? 1 : 0}"

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
        acm_certificate_arn = "${length(var.cloudfront_certificate_domain) == 0 ? "" : join("", data.aws_acm_certificate.website.*.arn)}"
        cloudfront_default_certificate = "${length(var.cloudfront_certificate_domain) == 0 ? 1 : 0}"

        minimum_protocol_version = "TLSv1"
        ssl_support_method = "sni-only"
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    origin {
        origin_id   = "S3-${var.project}-website"
        domain_name = "${aws_s3_bucket.website.bucket_regional_domain_name}"

        s3_origin_config {
            origin_access_identity = "${local.cloudfront_website_oai_path}"
        }
    }

    default_root_object = "${var.website_index_document}"
    default_cache_behavior {
        target_origin_id = "S3-${var.project}-website"
        viewer_protocol_policy = "${length(var.cloudfront_certificate_domain) == 0 ? "allow-all" : "redirect-to-https"}"

        allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
        cached_methods = [ "GET", "HEAD" ]
        min_ttl = "${var.cloudfront_min_ttl}"
        max_ttl = "${var.cloudfront_max_ttl}"
        default_ttl = "${var.cloudfront_default_ttl}"

        forwarded_values {
            cookies {
                forward = "none"
            }

            query_string = false
        }

        smooth_streaming = false
        compress = true
    }

    tags {
        Service = "${var.service}"
        Contact = "${var.contact}"
        Environment = "${var.environment}"

        Project = "${var.project}"
    }
}

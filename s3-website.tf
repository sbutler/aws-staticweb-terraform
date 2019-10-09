# =========================================================
# Data
# =========================================================

data "aws_iam_policy_document" "s3_website" {
    override_json = var.website_policy_json == null ? null : join("", data.template_file.website_policy_json[*].rendered)

    statement {
        sid = "PublicRead"

        effect = "Allow"
        actions = [ "s3:GetObject" ]
        principals {
            type        = "*"
            identifiers = [ "*" ]
        }
        resources = [
            "arn:aws:s3:::${local.name_prefix}web-${random_id.website.hex}/*",
        ]
    }
}

data "template_file" "website_error_page" {
    count = length(local.website_error_codes)

    template = file("${path.module}/templates/error.html")
    vars = {
        status_code  = local.website_error_codes[count.index]
        header_text  = local.website_error_headers[local.website_error_codes[count.index]]
        message_text = local.website_error_messages[local.website_error_codes[count.index]]
        contact      = var.website_error_contact
    }
}

# Allow the provided policy JSON to include template variables, such as the bucket
# name and ARN. This does mean jumping through some hoops later when we want to use
# it as an override_json.
data "template_file" "website_policy_json" {
    count = var.website_policy_json == null ? 0 : 1

    template = var.website_policy_json
    vars = {
        bucket     = "${local.name_prefix}web-${random_id.website.hex}"
        bucket_arn = "arn:aws:s3:::${local.name_prefix}web-${random_id.website.hex}"
    }
}


# =========================================================
# Locals
# =========================================================

locals {
    website_error_pngs = [
        "logo.png",
        "logo@2x.png",
        "logo@3x.png",
        "wordmark.png",
        "wordmark@2x.png",
        "wordmark@3x.png",
    ]

    website_error_codes = [ "400", "403", "404", "405", "414", "500", "501", "502", "503", "504" ]

    default_website_error_headers = {
        "400" = "Bad Request"
        "403" = "Forbidden"
        "404" = "Not Found"
        "405" = "Method Not Allowed"
        "414" = "Request-URI Too Large"
        "500" = "Internal Server Error"
        "501" = "Not Implemented"
        "502" = "Bad Gateway"
        "503" = "Service Unavailable"
        "504" = "Gateway Timeout"
    }
    website_error_headers = merge(
        local.default_website_error_headers,
        var.website_error_headers
    )

    default_website_error_messages = {
        "400" = "<p>Your browser (or proxy) sent a request that this server could not understand.</p>"
        "403" = "<p>You don't have permission to access the requested object. It is either read-protected or not readable by the server.</p>"
        "404" = "<p>The requested URL was not found on this server.</p>"
        "405" = "<p>The HTTP method is not allowed for the requested URL.</p>"
        "414" = "<p>The length of the requested URL exceeds the capacity limit for this server. The request cannot be processed.</p>"
        "500" = "<p>The server encountered an internal error and was unable to complete your request.</p>"
        "501" = "<p>The server does not support the action requested by the browser.</p>"
        "502" = "<p>The proxy server received an invalid response from an upstream server.</p>"
        "503" = "<p>The server is temporarily unable to service your request due to maintenance downtime or capacity problems. Please try again later.</p>"
        "504" = "<p>The proxy servier timed out waiting for a response from an upstream server.</p>"
    }
    website_error_messages = merge(
        local.default_website_error_messages,
        var.website_error_messages
    )
}

# =========================================================
# Resources
# =========================================================

resource "random_id" "website" {
    byte_length = 16
}

resource "aws_s3_bucket" "website" {
    bucket = "${local.name_prefix}web-${random_id.website.hex}"

    policy = data.aws_iam_policy_document.s3_website.json
    versioning {
        enabled = true
    }

    website {
        index_document = var.website_index_document
    }

    cors_rule {
        allowed_methods = [ "GET" ]
        allowed_origins = [ "*" ]
    }

    logging {
        target_bucket = local.logs_bucket
        target_prefix = var.website_logs_prefix
    }

    tags = {
        Service            = var.service
        Contact            = var.contact
        DataClassification = var.data_classification
        Environment        = var.environment
        Project            = var.project
    }

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_object" "website_favicon" {
    bucket = aws_s3_bucket.website.bucket
    key    = "favicon.ico"

    source = "${path.module}/files/favicon.ico"
    etag   = filemd5("${path.module}/files/favicon.ico")

    content_type  = "image/x-icon"
    cache_control = "public, max-age=604800"
}

resource "aws_s3_bucket_object" "website_error_png" {
    count = length(local.website_error_pngs)

    bucket = aws_s3_bucket.website.bucket
    key    = "error/${local.website_error_pngs[count.index]}"

    source = "${path.module}/files/${local.website_error_pngs[count.index]}"
    etag   = filemd5("${path.module}/files/${local.website_error_pngs[count.index]}")

    content_type  = "image/png"
    cache_control = "public, max-age=604800"
}

resource "aws_s3_bucket_object" "website_error_page" {
    count = length(local.website_error_codes)

    bucket = aws_s3_bucket.website.bucket
    key    = "error/${local.website_error_codes[count.index]}.html"

    content = data.template_file.website_error_page[count.index].rendered
    etag    = md5(data.template_file.website_error_page[count.index].rendered)

    content_type = "text/html"
}

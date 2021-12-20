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

    website_error_code_defaults = {
        "400" = {
            header  = "Bad Request"
            message = "<p>Your browser (or proxy) sent a request that this server could not understand.</p>"
            min_ttl = null
        }
        "403" = {
            header  = "Forbidden"
            message = "<p>You don't have permission to access the requested object. It is either read-protected or not readable by the server.</p>"
            min_ttl = null
        }
        "404" = {
            header  = "Not Found"
            message = "<p>The requested URL was not found on this server.</p>"
            min_ttl = 0
        }
        "405" = {
            header  = "Method Not Allowed"
            message = "<p>The HTTP method is not allowed for the requested URL.</p>"
            min_ttl = null
        }
        "414" = {
            header  = "Request-URI Too Large"
            message = "<p>The length of the requested URL exceeds the capacity limit for this server. The request cannot be processed.</p>"
            min_ttl = null
        }
        "500" = {
            header  = "Internal Server Error"
            message = "<p>The server encountered an internal error and was unable to complete your request.</p>"
            min_ttl = null
        }
        "501" = {
            header  = "Not Implemented"
            message = "<p>The server does not support the action requested by the browser.</p>"
            min_ttl = null
        }
        "502" = {
            header  = "Bad Gateway"
            message = "<p>The proxy server received an invalid response from an upstream server.</p>"
            min_ttl = null
        }
        "503" = {
            header  = "Service Unavailable"
            message = "<p>The server is temporarily unable to service your request due to maintenance downtime or capacity problems. Please try again later.</p>"
            min_ttl = null
        }
        "504" = {
            header  = "Gateway Timeout"
            message = "<p>The proxy servier timed out waiting for a response from an upstream server.</p>"
            min_ttl = null
        }
    }
    website_error_codes = { for k, d in local.website_error_code_defaults : k => {
        header  = lookup(var.website_error_headers,  k, d.header)
        message = lookup(var.website_error_messages, k, d.message)
        min_ttl = d.min_ttl

        content = templatefile(
            "${path.module}/templates/error.html",
            {
                status_code  = k
                header_text  = lookup(var.website_error_headers,  k, d.header)
                message_text = lookup(var.website_error_messages, k, d.message)
                contact      = var.website_error_contact
            }
        )
    } }

    website_bucket = "${local.name_prefix}web-${random_id.website.hex}"
}

# =========================================================
# Resources
# =========================================================

resource "random_id" "website" {
    byte_length = 16
}

module "website" {
    source = "./modules/website-bucket"

    data_classification = var.data_classification

    cf_useragent      = local.cf_useragent
    index_document    = var.website_index_document
    name              = local.website_bucket
    noncurrent_expire = var.website_noncurrent_expire

    logs_bucket = var.logs_bucket
    logs_expire = var.logs_expire
    logs_prefix = var.website_logs_prefix
}

# =========================================================
# Resources: Objects
# =========================================================

resource "aws_s3_bucket_object" "website_favicon" {
    depends_on = [
        aws_s3_bucket_replication_configuration.website_replication,
    ]

    bucket = module.website.bucket
    key    = "favicon.ico"

    source = "${path.module}/files/favicon.ico"
    etag   = filemd5("${path.module}/files/favicon.ico")

    content_type  = "image/x-icon"
    cache_control = "public, max-age=604800"
}

resource "aws_s3_bucket_object" "website_error_png" {
    for_each   = toset(local.website_error_pngs)
    depends_on = [
        aws_s3_bucket_replication_configuration.website_replication,
    ]

    bucket = module.website.bucket
    key    = "error/${each.key}"

    source = "${path.module}/files/${each.key}"
    etag   = filemd5("${path.module}/files/${each.key}")

    content_type  = "image/png"
    cache_control = "public, max-age=604800"
}

resource "aws_s3_bucket_object" "website_error_page" {
    for_each   = local.website_error_codes
    depends_on = [
        aws_s3_bucket_replication_configuration.website_replication,
    ]

    bucket = module.website.bucket
    key    = "error/${each.key}.html"

    content = each.value.content
    etag    = md5(each.value.content)

    content_type = "text/html"
}

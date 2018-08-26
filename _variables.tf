# =========================================================
# Cloud First
# =========================================================

variable "service" {
    type = "string"
    description = "Service name (match Service Catalog where possible)."
}

variable "contact" {
    type = "string"
    description = "Service email address."
}

variable "data_classification" {
    type = "string"
    description = "Public, Internal, Sensitive, or HighRisk (choose the most rigorous standard that applies)."
    default = "Public"
}

variable "environment" {
    type = "string"
    description = "Production, Test, Development, Green, Blue, etc."
    default = ""
}

variable "project" {
    type = "string"
    description = "Short, simple (letters, numbers, hyphen, underscore) project name that will be used as a prefix for resource names."
}


# =========================================================
# Website
# =========================================================

variable "website_index_document" {
    type = "string"
    description = "Name of the file to use for indexes of a folder."
    default = "index.html"
}

variable "website_logs_prefix" {
    type = "string"
    description = "Prefix to use for object keys for S3 logs (must end with a '/' or be empty)."
    default = "s3/"
}

variable "website_error_headers" {
    type = "map"
    description = "Map of HTTP Status Codes to error page header strings."
    default = {
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
}

variable "website_error_messages" {
    type = "map"
    description = "Map of HTTP Status Codes to error page message strings."
    default = {
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
}

variable "website_error_contact" {
    type = "string"
    description = "Email address to list as the contact on error pages."
    default = "consult@illinois.edu"
}

# =========================================================
# CloudFront (managed)
# =========================================================

variable "cloudfront_domains" {
    type = "list"
    description = "List of custom domains for CloudFront to answer to."
    default = []
}

variable "cloudfront_certificate_domain" {
    type = "string"
    description = "Domain name of the ACM certificate to use for CloudFront."
    default = ""
}

variable "cloudfront_min_ttl" {
    type = "string"
    description = "Minimum TTL for cached objects."
    default = "0"
}

variable "cloudfront_max_ttl" {
    type = "string"
    description = "Maximum TTL for cached objects."
    default = "31536000"
}

variable "cloudfront_default_ttl" {
    type = "string"
    description = "Default TTL for cached objects if the origin does not specify a lifetime."
    default = "0"
}

variable "cloudfront_logs_prefix" {
    type = "string"
    description = "Prefix to use for object keys for CloudFront logs (must end with a '/' or be empty)."
    default = "cloudfront/"
}


# =========================================================
# CloudFront (provided)
# =========================================================

variable "cloudfront_origin_access_identity_path" {
    type = "string"
    description = "CloudFront path for the provided origin access identity (must also specify cloudfront_origin_access_identity_iam_arn)."
    default = ""
}

variable "cloudfront_origin_access_identity_iam_arn" {
    type = "string"
    description = "IAM ARN for the origin access identity (must also specify cloudfront_origin_access_identity_path)."
    default = ""
}


# =========================================================
# CloudFront (provided)
# =========================================================

variable "logs_bucket" {
    type = "string"
    description = "Name of the bucket for logging. If not provided then a new bucket will be created."
    default = ""
}

variable "logs_expire" {
    type = "string"
    description = "How long before logs are expired (in days). This is only used if the logs_bucket variable is not specified."
    default = "30"
}

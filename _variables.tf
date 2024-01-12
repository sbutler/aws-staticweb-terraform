# =========================================================
# Cloud First
# =========================================================

variable "service" {
    type        = string
    description = "Service name (match Service Catalog where possible)."
}

variable "contact" {
    type        = string
    description = "Service email address."
}

variable "data_classification" {
    type        = string
    description = "Public, Internal, Sensitive, or HighRisk (choose the most rigorous standard that applies)."
    default     = "Public"
}

variable "environment" {
    type        = string
    description = "Production, Test, Development, Green, Blue, etc."
    default     = ""
}

variable "project" {
    type        = string
    description = "Short, simple (letters, numbers, hyphen, underscore) project name that will be used as a prefix for resource names."
}

variable "name_prefix" {
    type        = string
    description = "Short, simple (letters, numbers, hyphen, underscore) project name that will be used as a prefix for resource names. Defaults to '$project-'."
    default     = null
}


# =========================================================
# Website
# =========================================================

variable "website_index_document" {
    type        = string
    description = "Name of the file to use for indexes of a folder."
    default     = "index.html"
}

variable "website_logs_prefix" {
    type        = string
    description = "Prefix to use for object keys for S3 logs."
    default     = "s3/"

    validation {
        condition     = can(regex("^([^/].*/)?$", var.website_logs_prefix))
        error_message = "Must be empty, or not start with a '/' and end with a '/'."
    }
}

variable "website_error_headers" {
    type        = map(string)
    description = "Map of HTTP Status Codes to error page header strings."
    default     = {}
}

variable "website_error_messages" {
    type        = map(string)
    description = "Map of HTTP Status Codes to error page message strings."
    default     = {}
}

variable "website_error_contact" {
    type        = string
    description = "Email address to list as the contact on error pages."
    default     = "consult@illinois.edu"
}

variable "website_failover_logs_prefix" {
    type        = string
    description = "Prefix to use for object keys for S3 logs."
    default     = "s3/"

    validation {
        condition     = can(regex("^([^/].*/)?$", var.website_failover_logs_prefix))
        error_message = "Must be empty, or not start with a '/' and end with a '/'."
    }
}

# =========================================================
# CloudFront (managed)
# =========================================================

variable "cloudfront_enabled" {
    type        = bool
    description = "Enable managed CloudFront."
    default     = true
}

variable "cloudfront_domains" {
    type        = list(string)
    description = "List of custom domains for CloudFront to answer to."
    default     = null
}

variable "cloudfront_certificate_arn" {
    type        = string
    description = "ARN of the ACM certificate to use for CloudFront."
    default     = null
}

variable "cloudfront_min_ttl" {
    type        = number
    description = "Minimum TTL for cached objects."
    default     = 0
}

variable "cloudfront_max_ttl" {
    type        = number
    description = "Maximum TTL for cached objects."
    default     = 31536000
}

variable "cloudfront_default_ttl" {
    type        = number
    description = "Default TTL for cached objects if the origin does not specify a lifetime."
    default     = 0
}

variable "cloudfront_logs_prefix" {
    type        = string
    description = "Prefix to use for object keys for CloudFront logs."
    default     = "cloudfront/"

    validation {
        condition     = can(regex("^([^/].*/)?$", var.cloudfront_logs_prefix))
        error_message = "Must be empty, or not start with a '/' and end with a '/'."
    }
}


# =========================================================
# Logging
# =========================================================

variable "logs_bucket" {
    type        = string
    description = "Name of the bucket for logging. If not provided then a new bucket will be created."
    default     = null
}

variable "failover_logs_bucket" {
    type        = string
    description = "Name of the bucket for logging. If not provided then a new bucket will be created."
    default     = null
}

variable "logs_expire" {
    type        = number
    description = "How long before logs are expired (in days). This is only used if the logs_bucket variable is not specified."
    default     = 30
}

# =========================================================
# Cloud First
# =========================================================

variable "data_classification" {
    type        = string
    description = "Public, Internal, Sensitive, or HighRisk (choose the most rigorous standard that applies)."
    default     = "Public"
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

variable "mimetypes" {
    type        = map(string)
    description = "Map of file extensions to their mime-types. This is merged with the default included list."
    default     = {}
}

# =========================================================
# Website
# =========================================================

variable "website_objects" {
    type        = map(object({
                    source  = optional(string)
                    content = optional(string)

                    content_disposition = optional(string)
                    content_encoding    = optional(string)
                    content_type        = optional(string)

                    cache_control = optional(string)
                }))
    description = "Map of objects to sync to the website main bucket. This must be a value suitable for for_each (known at plan time)."
    default     = {}

    validation {
        condition     = alltrue([ for v in values(var.website_objects) : v.source != null || v.content != null ])
        error_message = "Either source or content must be specified."
    }

    validation {
        condition     = alltrue([ for v in values(var.website_objects) : v.source == null || v.content == null ])
        error_message = "Only one of source or content can be specified."
    }
}

variable "website_index_document" {
    type        = string
    description = "Name of the file to use for indexes of a folder."
    default     = "index.html"
}

variable "website_logs_prefix" {
    type        = string
    description = "Prefix to use for object keys for S3 logs of the main bucket."
    default     = "s3/"

    validation {
        condition     = can(regex("^([^/].*/)?$", var.website_logs_prefix))
        error_message = "Must be empty, or not start with a '/' and end with a '/'."
    }
}

variable "website_error_department" {
    type        = string
    description = "Department to use for the wordmark on error pages."
    default     = null
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
    description = "Prefix to use for object keys for S3 logs of the failover bucket."
    default     = "s3/"

    validation {
        condition     = can(regex("^([^/].*/)?$", var.website_failover_logs_prefix))
        error_message = "Must be empty, or not start with a '/' and end with a '/'."
    }
}

variable "website_noncurrent_expire" {
    type        = number
    description = "Number of days before expiring non-current versions of objects. Set to 0 to not expire."
    default     = 0
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
    default     = []
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

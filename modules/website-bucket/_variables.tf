# =========================================================
# Cloud First
# =========================================================

variable "data_classification" {
    type        = string
    description = "Public, Internal, Sensitive, or HighRisk (choose the most rigorous standard that applies)."
    default     = "Public"
}

# =========================================================
# Settings
# =========================================================

variable "cf_useragent" {
    type        = string
    description = "CloudFront custom User-Agent string, to limit access."
    default     = null
}

variable "index_document" {
    type        = string
    description = "Name of the file to use for indexes of a folder."
    default     = "index.html"
}

variable "name" {
    type        = string
    description = "Name of the S3 bucket."
}

variable "noncurrent_expire" {
    type        = number
    description = "Number of days before expiring non-current versions of objects. Set to 0 to not expire."
    default     = 0
}

# =========================================================
# Logs
# =========================================================

variable "logs_bucket" {
    type        = string
    description = "Name of the bucket for logging. If not provided then a new bucket will be created."
    default     = null
}

variable "logs_expire" {
    type        = number
    description = "How long before logs are expired (in days). This is only used if the logs_bucket variable is not specified."
    default     = 30
}

variable "logs_prefix" {
    type        = string
    description = "Prefix to use for object keys for S3 logs."
    default     = "s3/"

    validation {
        condition     = can(regex("^([^/].*/)?$", var.logs_prefix))
        error_message = "Must be empty, or not start with a '/' and end with a '/'."
    }
}

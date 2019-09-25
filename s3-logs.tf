# =========================================================
# Locals
# =========================================================

locals {
    logs_bucket = var.logs_bucket == null ? join("", aws_s3_bucket.logs[*].id) : var.logs_bucket
}


# =========================================================
# Resources
# =========================================================

resource "aws_s3_bucket" "logs" {
    count = var.logs_bucket == null ? 1 : 0

    bucket = "${local.name_prefix}log-${random_id.website.hex}"
    acl    = "log-delivery-write"

    versioning {
        enabled = false
    }

    lifecycle_rule {
        id      = "Logs-Expire"
        enabled = true

        expiration {
            days = var.logs_expire
        }
    }

    tags = {
        Service            = var.service
        Contact            = var.contact
        DataClassification = var.data_classification == "Public" ? "Internal" : var.data_classification
        Environment        = var.environment
        Project            = var.project
    }

    lifecycle {
        prevent_destroy = true
    }
}

# =========================================================
# Data
# =========================================================

data "aws_s3_bucket" "logs" {
    count = var.logs_bucket == null ? 0 : 1

    bucket = var.logs_bucket
}

# =========================================================
# Locals
# =========================================================

locals {
    logs_bucket = coalesce(
        join("", data.aws_s3_bucket.logs[*].bucket),
        join("", aws_s3_bucket.logs[*].bucket),
    )
}

# =========================================================
# Resources
# =========================================================

resource "aws_s3_bucket" "logs" {
    count = var.logs_bucket == null ? 1 : 0

    bucket = "logs-${var.name}"
    acl    = "log-delivery-write"

    versioning {
        enabled = false
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm     = "AES256"
            }
        }
    }

    lifecycle_rule {
        id      = "ExpireLogs"
        enabled = true

        expiration {
            days = var.logs_expire
        }
    }

    tags = {
        DataClassification = var.data_classification == "Public" ? "Internal" : var.data_classification
    }

    lifecycle {
        #prevent_destroy = true
    }
}

resource "aws_s3_bucket_public_access_block" "logs" {
    count = var.logs_bucket == null ? 1 : 0

    bucket = aws_s3_bucket.logs[count.index].id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "logs" {
    count = var.logs_bucket == null ? 1 : 0

    bucket = aws_s3_bucket.logs[count.index].id
    name   = "ArchiveLogs"

    tiering {
        access_tier = "ARCHIVE_ACCESS"
        days        = 90
    }
}

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
    logs_bucket = var.logs_bucket == null ? aws_s3_bucket.logs[0].bucket : data.aws_s3_bucket.logs[0].bucket
}

# =========================================================
# Resources
# =========================================================

resource "aws_s3_bucket" "logs" {
    count = var.logs_bucket == null ? 1 : 0

    bucket = "logs-${var.name}"

    tags = {
        DataClassification = var.data_classification == "Public" ? "Internal" : var.data_classification
    }

    lifecycle {
        #prevent_destroy = true
    }
}

resource "aws_s3_bucket_acl" "logs" {
    count = var.logs_bucket == null ? 1 : 0
    depends_on = [
        aws_s3_bucket_ownership_controls.logs,
    ]

    bucket = aws_s3_bucket.logs[count.index].id
    acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
    count = var.logs_bucket == null ? 1 : 0

    bucket = aws_s3_bucket.logs[count.index].id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
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

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
    count = var.logs_bucket == null ? 1 : 0

    bucket = aws_s3_bucket.logs[count.index].id

    rule {
        id     = "IntelligentTiering"
        status = "Enabled"

        transition {
            days          = 1
            storage_class = "INTELLIGENT_TIERING"
        }
    }

    rule {
        id     = "Expire"
        status = var.logs_expire > 0 ? "Enabled" : "Disabled"

        expiration {
            days = var.logs_expire == 0 ? 999 : var.logs_expire
        }

        noncurrent_version_expiration {
            noncurrent_days = 7
        }
    }

    rule {
        id     = "CleanUp"
        status = "Enabled"

        abort_incomplete_multipart_upload {
            days_after_initiation = 7
        }

        expiration {
            expired_object_delete_marker = true
        }
    }
}

resource "aws_s3_bucket_ownership_controls" "logs" {
    count = var.logs_bucket == null ? 1 : 0

    bucket = aws_s3_bucket.logs[count.index].id

    rule {
        object_ownership = "BucketOwnerPreferred"
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

resource "aws_s3_bucket_versioning" "logs" {
    count = var.logs_bucket == null ? 1 : 0

    bucket = aws_s3_bucket.logs[count.index].id

    versioning_configuration {
        status = "Disabled"
    }
}

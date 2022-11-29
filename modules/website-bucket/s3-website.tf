# =========================================================
# Data
# =========================================================

data "aws_iam_policy_document" "this_s3" {
    statement {
        sid    = "CloudFrontRead"
        effect = "Allow"

        actions = [ "s3:GetObject" ]

        resources = [
            "arn:${local.partition}:s3:::${var.name}/*",
        ]

        principals {
            type        = "*"
            identifiers = [ "*" ]
        }

        dynamic "condition" {
            for_each = compact([ var.cf_useragent ])
            content {
                test     = "StringEquals"
                variable = "aws:UserAgent"
                values   = [ condition.value ]
            }
        }
    }
}

# =========================================================
# Resources
# =========================================================

resource "aws_s3_bucket" "this" {
    bucket = var.name

    tags = {
        DataClassification = var.data_classification
    }

    lifecycle {
        ignore_changes = [
            replication_configuration
        ]

        #prevent_destroy = true
    }
}

resource "aws_s3_bucket_cors_configuration" "this" {
    bucket = aws_s3_bucket.this.id

    cors_rule {
        allowed_methods = [ "GET" ]
        allowed_origins = [ "*" ]
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
    bucket = aws_s3_bucket.this.id

    dynamic "rule" {
        for_each = [ 1, 7, 30, 90, 365 ]
        content {
            id     = "NonCurrentExpire${rule.value}"
            status = "Enabled"

            filter {
                and {
                    tags = {
                        NonCurrentExpire = tostring(rule.value)
                    }
                }
            }

            noncurrent_version_expiration {
                noncurrent_days = rule.value
            }
        }
    }

    rule {
        id     = "NonCurrentExpire-Default"
        status = var.noncurrent_expire > 0 ? "Enabled" : "Disabled"

        noncurrent_version_expiration {
            noncurrent_days = var.noncurrent_expire == 0 ? 999 : var.noncurrent_expire
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

resource "aws_s3_bucket_logging" "this" {
    depends_on = [
        aws_s3_bucket_acl.logs,
        aws_s3_bucket_server_side_encryption_configuration.logs,
        aws_s3_bucket_intelligent_tiering_configuration.logs,
        aws_s3_bucket_lifecycle_configuration.logs,
        aws_s3_bucket_public_access_block.logs,
        aws_s3_bucket_versioning.logs,
    ]

    bucket = aws_s3_bucket.this.id

    target_bucket = local.logs_bucket
    target_prefix = var.logs_prefix
}

resource "aws_s3_bucket_policy" "this" {
    bucket = aws_s3_bucket.this.id

    policy = data.aws_iam_policy_document.this_s3.json
}

resource "aws_s3_bucket_versioning" "this" {
    bucket = aws_s3_bucket.this.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_website_configuration" "this" {
    bucket = aws_s3_bucket.this.bucket

    index_document {
        suffix = var.index_document
    }
}

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

    policy = data.aws_iam_policy_document.this_s3.json
    versioning {
        enabled = true
    }

    cors_rule {
        allowed_methods = [ "GET" ]
        allowed_origins = [ "*" ]
    }

    website {
        index_document = var.index_document
    }

    logging {
        target_bucket = local.logs_bucket
        target_prefix = var.logs_prefix
    }

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

# =========================================================
# Data
# =========================================================

data "aws_iam_policy_document" "s3_website_failover" {
    statement {
        sid    = "CloudFrontRead"
        effect = "Allow"

        actions = [ "s3:GetObject" ]

        resources = [
            "arn:${local.partition}:s3:::${local.website_failover_bucket}/*",
        ]

        principals {
            type        = "*"
            identifiers = [ "*" ]
        }

        dynamic "condition" {
            for_each = var.cloudfront_enabled ? [ local.cf_useragent ] : []
            content {
                test     = "StringEquals"
                variable = "aws:UserAgent"
                values   = [ condition.value ]
            }
        }
    }
}

data "aws_iam_policy_document" "website_replication" {
    statement {
        effect = "Allow"

        actions = [
            "s3:GetReplicationConfiguration",
            "s3:ListBucket",
        ]

        resources = [
            "arn:${local.partition}:s3:::${local.website_bucket}",
        ]
    }

    statement {
        effect = "Allow"

        actions = [
            "s3:GetObjectVersionForReplication",
            "s3:GetObjectVersionAcl",
            "s3:GetObjectVersionTagging",
        ]

        resources = [
            "arn:${local.partition}:s3:::${local.website_bucket}",
        ]
    }

    statement {
        effect = "Allow"

        actions = [
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ReplicateTags",
        ]
        resources = [
            "arn:${local.partition}:s3:::${local.website_failover_bucket}/*"
        ]
    }
}

# =========================================================
# Locals
# =========================================================

locals {
    website_failover_bucket = "${local.name_prefix}web-failover-${random_id.website.hex}"
}

# =========================================================
# Resources: IAM
# =========================================================

resource "aws_iam_role" "website_replication" {
    count = var.cloudfront_enabled ? 1 : 0

    name_prefix = "${local.name_prefix}web-"
    description = "Role for replication to the ${var.project} failover bucket."

    assume_role_policy = data.aws_iam_policy_document.assume_s3.json
}

resource "aws_iam_role_policy" "website_replication" {
    count = var.cloudfront_enabled ? 1 : 0

    name = "replication"

    role   = aws_iam_role.website_replication[count.index].id
    policy = data.aws_iam_policy_document.website_replication.json
}

resource "time_sleep" "waitfor_website_replication_role" {
    count = var.cloudfront_enabled ? 1 : 0

    create_duration = "10s"

    triggers = {
        role   = aws_iam_role.website_replication[count.index].arn
        policy = aws_iam_role_policy.website_replication[count.index].id
    }
}

# =========================================================
# Resources
# =========================================================

resource "aws_s3_bucket" "website_failover" {
    count    = var.cloudfront_enabled ? 1 : 0
    provider = aws.failover

    bucket = local.website_failover_bucket

    policy = data.aws_iam_policy_document.s3_website_failover.json
    versioning {
        enabled = true
    }

    cors_rule {
        allowed_methods = [ "GET" ]
        allowed_origins = [ "*" ]
    }

    website {
        index_document = var.website_index_document
    }

    logging {
        target_bucket = local.logs_bucket
        target_prefix = var.website_logs_prefix
    }

    tags = {
        DataClassification = var.data_classification
    }

    lifecycle {
        #prevent_destroy = true
    }
}

resource "aws_s3_bucket_replication_configuration" "website_replication" {
    count      = var.cloudfront_enabled ? 1 : 0
    depends_on = [
        time_sleep.waitfor_website_replication_role,
    ]

    role   = aws_iam_role.website_replication[count.index].arn
    bucket = aws_s3_bucket.website.id

    rule {
        id     = "failover"
        status = "Enabled"

        destination {
            bucket = aws_s3_bucket.website_failover[count.index].arn
        }
    }
}

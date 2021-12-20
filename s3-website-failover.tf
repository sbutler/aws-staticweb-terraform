# =========================================================
# Data
# =========================================================

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
            "arn:${local.partition}:s3:::${local.website_bucket}/*",
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
# Resources
# =========================================================

module "website_failover" {
    count     = var.cloudfront_enabled ? 1 : 0
    source    = "./modules/website-bucket"
    providers = {
        aws = aws.failover
    }

    data_classification = var.data_classification

    cf_useragent   = local.cf_useragent
    index_document = var.website_index_document
    name           = local.website_failover_bucket

    logs_bucket = var.failover_logs_bucket
    logs_expire = var.logs_expire
    logs_prefix = var.website_failover_logs_prefix
}

# =========================================================
# Resources: Replication IAM
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
# Resources: Replication
# =========================================================

resource "aws_s3_bucket_replication_configuration" "website_replication" {
    count      = var.cloudfront_enabled ? 1 : 0
    depends_on = [
        time_sleep.waitfor_website_replication_role,
    ]

    role   = aws_iam_role.website_replication[count.index].arn
    bucket = module.website.bucket

    rule {
        id     = "failover"
        status = "Enabled"

        destination {
            bucket = module.website_failover[count.index].arn
        }
    }
}

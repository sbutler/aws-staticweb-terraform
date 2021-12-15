# =========================================================
# Data
# =========================================================

data "aws_partition" "current" {}

# =========================================================
# Locals
# =========================================================

locals {
    partition = data.aws_partition.current.partition

    name_prefix = coalesce(var.name_prefix, "${var.project}-")
}

# =========================================================
# Data: Assume
# =========================================================

data "aws_iam_policy_document" "assume_s3" {
    statement {
        effect = "Allow"

        actions = [ "sts:AssumeRole" ]

        principals {
            type = "Service"
            identifiers = [ "s3.amazonaws.com" ]
        }
    }
}

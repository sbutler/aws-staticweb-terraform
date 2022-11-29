# =========================================================
# Data
# =========================================================

data "aws_iam_policy_document" "website_ReadOnlyAccess" {
    statement {
        sid    = "S3Global"
        effect = "Allow"

        actions = [
            "s3:GetAccountPublicAccessBlock",
            "s3:ListAccessPoints",
            "s3:ListAllMyBuckets",
        ]
        resources = [ "*" ]
    }

    statement {
        sid    = "S3Bucket"
        effect = "Allow"

        actions = [
            "s3:GetBucketAcl",
            "s3:GetBucketLocation",
            "s3:GetBucketObjectLockConfiguration",
            "s3:GetBucketObjectOwnership",
            "s3:GetBucketOwnershipControls",
            "s3:GetBucketPolicyStatus",
            "s3:GetBucketPublicAccessBlock",
            "s3:GetBucketTagging",
            "s3:GetBucketVersioning",
            "s3:GetBucketWebsite",
            "s3:GetEncryptionConfiguration",
            "s3:ListBucket",
            "s3:ListBucketVersions",
        ]

        resources = [
            "arn:${local.partition}:s3:::${local.website_bucket}",
        ]
    }

    statement {
        sid    = "S3ObjectRead"
        effect = "Allow"

        actions = [
            "s3:GetObject*",
        ]

        resources = [
            "arn:${local.partition}:s3:::${local.website_bucket}/*",
        ]
    }
}

data "aws_iam_policy_document" "website_ReadWriteAccess" {
    source_policy_documents = [
        data.aws_iam_policy_document.website_ReadOnlyAccess.json,
    ]

    statement {
        sid    = "S3ObjectWrite"
        effect = "Allow"

        actions = [
            "s3:AbortMultipartUpload",
            "s3:DeleteObject*",
            "s3:GetEncryptionConfiguration",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject*",
            "s3:RestoreObject",
        ]

        resources = [
            "arn:${local.partition}:s3:::${local.website_bucket}/*",
        ]
    }
}

# =========================================================
# Data
# =========================================================

resource "aws_iam_policy" "website_ReadOnlyAccess" {
    name        = "${var.project}-ReadOnlyAccess"
    description = "Read-only access to the ${var.project} S3 website bucket."

    policy = data.aws_iam_policy_document.website_ReadOnlyAccess.json
}

resource "aws_iam_policy" "website_ReadWriteAccess" {
    name        = "${var.project}-ReadWriteAccess"
    description = "Read-write access to the ${var.project} S3 website bucket."

    policy = data.aws_iam_policy_document.website_ReadWriteAccess.json
}

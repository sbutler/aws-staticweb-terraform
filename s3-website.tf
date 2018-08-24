# =========================================================
# Data
# =========================================================

data "aws_iam_policy_document" "s3_website" {
    statement {
        sid = "CloudFront-Read"

        effect = "Allow"
        actions = [
            "s3:GetObject",
        ]
        principals {
            type = "AWS"
            identifiers = [ "${local.cloudfront_website_oai_iam_arn}" ]
        }
        resources = [
            "arn:aws:s3:::${var.project}-website-${random_id.website.hex}/*",
        ]
    }

    statement {
        sid = "CloudFront-List"

        effect = "Allow"
        actions = [
            "s3:ListBucket",
        ]
        principals {
            type = "AWS"
            identifiers = [ "${local.cloudfront_website_oai_iam_arn}" ]
        }
        resources = [
            "arn:aws:s3:::${var.project}-website-${random_id.website.hex}",
        ]
    }
}


# =========================================================
# Resources
# =========================================================

resource "random_id" "website" {
    byte_length = 8
}

resource "aws_s3_bucket" "website" {
    bucket = "${var.project}-website-${random_id.website.hex}"

    policy = "${data.aws_iam_policy_document.s3_website.json}"
    versioning {
        enabled = true
    }

    logging {
        target_bucket = "${local.logs_bucket}"
        target_prefix = "${var.website_logs_prefix}"
    }

    tags {
        Service = "${var.service}"
        Contact = "${var.contact}"
        DataClassification = "${var.data_classification}"
        Environment = "${var.environment}"

        Project = "${var.project}"
    }

    lifecycle {
        #prevent_destroy = true
    }
}

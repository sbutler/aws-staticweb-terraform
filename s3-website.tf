# =========================================================
# Data
# =========================================================

data "aws_iam_policy_document" "s3_website" {
    statement {
        sid = "PublicRead"

        effect = "Allow"
        actions = [
            "s3:GetObject",
        ]
        principals {
            type = "*"
            identifiers = [ "*" ]
        }
        resources = [
            "arn:aws:s3:::${var.project}-web-${random_id.website.hex}/*",
        ]
    }
}

data "template_file" "website_error_page" {
    count = "${length(local.website_error_codes)}"

    template = "${file("${path.module}/templates/error.html")}"
    vars {
        status_code = "${element(local.website_error_codes, count.index)}"
        header_text = "${lookup(var.website_error_headers, element(local.website_error_codes, count.index))}"
        message_text = "${lookup(var.website_error_messages, element(local.website_error_codes, count.index))}"
        contact = "${var.website_error_contact}"
    }
}


# =========================================================
# Locals
# =========================================================

locals {
    website_error_pngs = [
        "logo.png",
        "logo@2x.png",
        "logo@3x.png",
        "wordmark.png",
        "wordmark@2x.png",
        "wordmark@3x.png",
    ]

    website_error_codes = [ "400", "403", "404", "405", "414", "500", "501", "502", "503", "504" ]
}

# =========================================================
# Resources
# =========================================================

resource "random_id" "website" {
    byte_length = 16
}

resource "aws_s3_bucket" "website" {
    bucket = "${var.project}-web-${random_id.website.hex}"

    policy = "${data.aws_iam_policy_document.s3_website.json}"
    versioning {
        enabled = true
    }

    website {
        index_document = "${var.website_index_document}"
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

resource "aws_s3_bucket_object" "website_favicon" {
    bucket = "${aws_s3_bucket.website.bucket}"
    key = "favicon.ico"

    source = "${path.module}/files/favicon.ico"
    etag = "${md5(file("${path.module}/files/favicon.ico"))}"

    content_type = "image/x-icon"
    cache_control = "public, max-age=604800"
}

resource "aws_s3_bucket_object" "website_error_png" {
    count = "${length(local.website_error_pngs)}"

    bucket = "${aws_s3_bucket.website.bucket}"
    key = "error/${element(local.website_error_pngs, count.index)}"

    source = "${path.module}/files/${element(local.website_error_pngs, count.index)}"
    etag = "${md5(file("${path.module}/files/${element(local.website_error_pngs, count.index)}"))}"

    content_type = "image/png"
    cache_control = "public, max-age=604800"
}

resource "aws_s3_bucket_object" "website_error_page" {
    count = "${length(local.website_error_codes)}"

    bucket = "${aws_s3_bucket.website.bucket}"
    key = "error/${element(local.website_error_codes, count.index)}.html"

    content = "${element(data.template_file.website_error_page.*.rendered, count.index)}"
    etag = "${md5(element(data.template_file.website_error_page.*.rendered, count.index))}"

    content_type = "text/html"
}

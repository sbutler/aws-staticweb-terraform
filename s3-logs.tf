# =========================================================
# Locals
# =========================================================

locals {
    logs_bucket = "${
        length(var.logs_bucket) == 0
        ? join("", aws_s3_bucket.logs.*.id)
        : var.logs_bucket
    }"
}


# =========================================================
# Resources
# =========================================================

resource "aws_s3_bucket" "logs" {
    count = "${length(var.logs_bucket) == 0 ? 1 : 0}"

    bucket = "${var.project}-log-${random_id.website.hex}"
    acl = "log-delivery-write"

    versioning {
        enabled = false
    }

    lifecycle_rule {
        id = "Logs-Expire"
        enabled = true

        expiration {
            days = "${var.logs_expire}"
        }
    }


    tags {
        Service = "${var.service}"
        Contact = "${var.contact}"
        DataClassification = "${var.data_classification == "Public" ? "Internal" : var.data_classification}"
        Environment = "${var.environment}"

        Project = "${var.project}"
    }

    lifecycle {
        #prevent_destroy = true
    }
}

# =========================================================
# Data
# =========================================================

data "aws_acm_certificate" "website" {
    count = "${length(var.cloudfront_certificate_domain) == 0 ? 0 : 1}"

    domain = "${var.cloudfront_certificate_domain}"
    statuses = [ "ISSUED" ]
    most_recent = true
}

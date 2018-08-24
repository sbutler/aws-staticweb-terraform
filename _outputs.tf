output "cloudfront_domain" {
    value = "${join("", aws_cloudfront_distribution.website.*.domain_name)}"
}

output "website_bucket" {
    value = "${aws_s3_bucket.website.bucket}"
}

output "website_bucket_domain_name" {
    value = "${aws_s3_bucket.website.bucket_domain_name}"
}

output "website_bucket_regional_domain_name" {
    value = "${aws_s3_bucket.website.bucket_regional_domain_name}"
}

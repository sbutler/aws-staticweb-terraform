# =========================================================
# Outputs
# =========================================================

output "bucket" {
    value = aws_s3_bucket.this.bucket
}

output "arn" {
    value = aws_s3_bucket.this.arn
}

output "website_endpoint" {
    value = aws_s3_bucket.this.website_endpoint
}

output "bucket_regional_domain_name" {
    value = aws_s3_bucket.this.bucket_regional_domain_name
}

output "logs_bucket" {
    value = local.logs_bucket
}

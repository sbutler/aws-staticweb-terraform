output "cloudfront_domain" {
    value = var.cloudfront_enabled ? join("", aws_cloudfront_distribution.website[*].domain_name) : null
}

output "website" {
    value = {
        bucket               = aws_s3_bucket.website.bucket
        endpoint             = aws_s3_bucket.website.website_endpoint
        regional_domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    }
}

output "website_failover" {
    value = var.cloudfront_enabled ? {
        bucket               = join("", aws_s3_bucket.website_failover[*].bucket)
        endpoint             = join("", aws_s3_bucket.website_failover[*].website_endpoint)
        regional_domain_name = join("", aws_s3_bucket.website_failover[*].bucket_regional_domain_name)
    } : {
        bucket               = null
        endpoint             = null
        regional_domain_name = null
    }
}

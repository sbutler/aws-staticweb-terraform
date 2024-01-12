output "cloudfront_domain" {
    value = var.cloudfront_enabled ? join("", aws_cloudfront_distribution.website[*].domain_name) : null
}

output "website" {
    value = {
        bucket               = module.website.bucket
        endpoint             = module.website.website_endpoint
        regional_domain_name = module.website.bucket_regional_domain_name
    }
}

output "website_failover" {
    value = var.cloudfront_enabled ? {
        bucket               = join("", module.website_failover[*].bucket)
        endpoint             = join("", module.website_failover[*].website_endpoint)
        regional_domain_name = join("", module.website_failover[*].bucket_regional_domain_name)
    } : {
        bucket               = null
        endpoint             = null
        regional_domain_name = null
    }
}

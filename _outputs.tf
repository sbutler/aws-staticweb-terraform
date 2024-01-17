output "cloudfront_domain" {
    value = var.cloudfront_enabled ? aws_cloudfront_distribution.website[0].domain_name : null
}

output "website" {
    value = {
        bucket               = module.website.bucket
        endpoint             = module.website.website_endpoint
        regional_domain_name = module.website.bucket_regional_domain_name
    }
}

output "website_failover" {
    value = local.website_failover_enabled ? {
        bucket               = module.website_failover[0].bucket
        endpoint             = module.website_failover[0].website_endpoint
        regional_domain_name = module.website_failover[0].bucket_regional_domain_name
    } : null
}

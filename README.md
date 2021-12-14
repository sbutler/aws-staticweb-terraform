# AWS Static Website

This is a terraform configuration to help you with best practices when
deploying a static website in AWS using S3 and CloudFront. It was
designed to be used as a module or standalone configuration.

Basic requirements for deploying this configuration:

* terraform >= 1.1.0

## Security

No attempt is made to restrict access to the web S3 bucket or objects
in it. Clients who discover the web S3 bucket name can make direct
requests to it bypassing CloudFront. Do not store anything other than
Public data in the web S3 bucket!

## Custom Domains and SSL Certificate

If you only care about insecure traffic to your website then you do
not need to import an SSL certificate. However, if you'd like to use
HTTPS or HTTP/2 then you will need to import or request an AWS
Certificate Manager (ACM) certificate in the N. Virginia (us-east-1)
region.

**Note: it is required that the certificate be in the N. Virginia
(us-east-1) region. CloudFront will not use certificates in other
regions.**

Instructions for ACM certificates. You can either import a certificate
or request one from AWS for free:

- [Importing Certificates into AWS Certificate Manager](https://docs.aws.amazon.com/acm/latest/userguide/import-certificate.html).
  You can follow this process to import a certificate issued by InCommon
  or any other certificate authority (including private certificate
  authorities).
- For [AWS issued certificates](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html) you will need to follow either "[Use DNS to Validate Domain Ownership](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-validate-dns.html)"
  or "[Use Email to Validate Domain Ownership](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-validate-email.html)"

## Variables

This configuration has several variables you can use to customize how
it is deployed. Variables in bold and without a default value are
required.

### Cloud First

These variables are standard ones required by Technology Services.

| Variable                | Default    | Example                  | Description |
| ----------------------- | ---------- | ------------------------ | ----------- |
| **service**             |            | `"Example"`              | Service Catalog name for the service this website is a part of. |
| **contact**             |            | `"example@illinois.edu"` | Internal contact email for who to notify for problems with resources. |
| data_classification     | `"Public"` | `"Internal"`             | Illini Secure data classification for data stored on the resources. Since no attempt is made to restrict the web bucket you should not use anything other than "Public" here. |
| environment             | `""`       | `"Dev"`                  | Production, Test, Development, etc. |
| **project**             |            | `"example"               | Short, simple (letters, numbers, hyphen, underscore) project name that will be used as the prefix for all named resources. |

### Website

These variables change how the website behaves.

| Variable                | Default                  | Example                  | Description |
| ----------------------- | ------------------------ | ------------------------ | ----------- |
| website_index_document  | `"index.html"`           | `"homepage.html"`        | Filename to use when a URL requests a directory. |
| website_logs_prefix     | `"s3/"`                  | `"example/s3/"`          | Prefix to use when storing S3 logs in a logging bucket **(must end in a "/")**. You can use the same logging bucket for multiple services by changing this prefix. |
| website_error_headers   | (varies)                 |                          | This is a map of HTTP Status Code to text to display in the header element of the error page. You can override individual header texts by changing this variable. |
| website_error_messages  | (varies)                 |                          | This is a map of HTTP Status Code to text to display in the message element of the error page. Full HTML is allowed here. You can override individual message texts by changing this variable. |
| website_error_contact   | `"consult@illinois.edu"` | `"example@illinois.edu"` | Email address to list as the contact on error pages. |

### CloudFront

These variables change how CloudFront behaves. You can disabled the
terraform's CloudFront entirely by setting the `cloudfront_enabled`
variable. If `false` then a CloudFront distribution will not be
created. This could be useful if you have a complex CloudFront
distribution you'd like to use.

CloudFront is required to provide HTTPS, HTTP/2, and custom domain
support for your website.

| Variable                   | Default       | Example                    | Description |
| -------------------------- | ------------- | -------------------------- | ----------- |
| cloudfront_enabled         | `true`        | `false`                    | Enable the managed CloudFront. |
| cloudfront_domains         | `[]`          | `["example.illinois.edu"]` | List of custom domains for your website. Any custom domain will have to be requested using the standard process and then specified here. |
| cloudfront_certificate_arn | `null`        | (ACM cert arn)             | ARN of a certificate requested or imported into AWS Certificate Manager (ACM). This certificate must be in N. Virginia (us-east-1) for CloudFront to use it. If not specified then your website will not be available on HTTPS or HTTP/2. |
| cloudfront_min_ttl         | `0`           | `3600`                     | Minimum allowed TTL for cached objects. |
| cloudfront_max_ttl         | `31536000`    | `86400`                    | Maximum allowed TTL for cached objects. |
| cloudfront_default_ttl     | `0`           | `600`                      | Default amount of time to cache objects when otherwise not specified by the origin. You can change this value for specific files when uploading to the web S3 bucket by setting their Cache-Control metadata. |
| cloudfront_logs_prefix     | `cloudfront/` | `example/cloudfront/`      | Prefix to use when storing CloudFront logs in a logging bucket **(must end in a "/")**. You can use the same logging bucket for multiple services by changing this prefix. |

### Logging

These variables change how logs are stored. You can choose to log to
an existing bucket or let the terraform create a logging bucket for
you. If the terraform creates a bucket then it is private.

| Variable                | Default | Example          | Description |
| ----------------------- | ------- | ---------------- | ----------- |
| logs_bucket             | `null`  | `"example-logs"` | Name of the bucket to store logs in. If not provided then a new, private bucket will be created. |
| lgos_expire             | `30`    | `90`             | Number of days to wait before deleting log files. This is only used if `logs_bucket` is not specified. |

## Outputs

The terraform configuration outputs several values for you to use.

| Value             | Description |
| ----------------- | ----------- |
| cloudfront_domain | Domain name of your static website. You can create a CNAME to this in DNS to use custom domains (if configured in `cloudfront_domains`). If you need to create A or AAAA records then you will have to use AWS Route53 with aliases to this domain. |
| website_bucket    | Name of the S3 bucket for your website content. |
| website_endpoint  | Domain name for your S3 bucket that handles website operations like index redirection. If you are using a custom CloudFront distribution then use this as a custom origin. |

# AWS Static Website

This is a terraform configuration to help you with best practices when
deploying a static website in AWS using S3 and CloudFront. It was
designed to be used as a module.

If you enable CloudFront then this terraform also deploys a failover bucket
in a different region, with content automatically copied from the primary
bucket. This gives you cheap failover capabilities in case of a region outage.

Basic requirements for deploying this configuration:

* terraform >= 1.6.2

## Security

An attempt is made to restrict direct access to the web S3 buckets by using
a custom User-Agent string. The value for this header should be kept
confidential. However, this is not a completely secure solution and you should
not store anything other than Public data in the web S3 buckets!

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

## Non-Current Object Versions

When you upload a new file (object) the existing file is kept as a "non-current
version" in the bucket. You can use the `website_noncurrent_expire` variable
to control how long these old versions are retained:

- `0`: old versions are not removed.
- `> 0`: old versions are retained for this many days.

Additionally, you can tag files with `NonCurrentExpire` and a value of `1`,
`7`, `30`, `90`, or `365` to keep the old version for a specific time.
**Warning: you cannot use the tags to keep an old version longer than what
you specify for `website_noncurrent_expire`.**

## Error Pages

When using the CloudFront distribution this module provides custom error pages
using the University of Illinois Theme. You can change some values in these
error pages using the module environment variables.

Error pages and assets are stored in the S3 buckets under the `.error/` prefix.
Do not upload your own objects under this prefix, and any changes you make to
managed objects will be overwriten the next time the terraform is run.

## Variables

This configuration has several variables you can use to customize how
it is deployed. Variables in bold and without a default value are
required.

### Cloud First

These variables are standard ones required by Technology Services.

| Variable            | Default    | Example      | Description |
| ------------------- | ---------- | ------------ | ----------- |
| data_classification | `"Public"` | `"Internal"` | Illini Secure data classification for data stored on the resources. Since no attempt is made to restrict the web bucket you should not use anything other than "Public" here. |
| **project**         |            | `"example"   | Short, simple (letters, numbers, hyphen, underscore) project name that will be used as the prefix for all named resources. |
| name_prefix         | `null`     | `"example-"` | Short, simple (letters, numbers, hyphen, underscore) project name that will be used as a prefix for resource names. Defaults to `"${var.project}-"` |
| mimetypes           | `{}`       | See example  | Map of file extensions to their mime-types. This is merged with the default included list. |

#### mimetypes

A default list of file extension to mimetypes is included, largely taken from
the mimetype mapping defined in the Apache HTTPD project. You can override any
of the defaults or add your own mimetypes by specifying this variable.

- Override: specify the extension as the key and the new mimetype as the value.
  If you would like to use just the global default type then specify `null`.
- Add: specify the extension as the key and the new mimetype.

```hcl2
mimetypes = {
  ".foo" = "application/x-foo"
}
```

### Website

These variables change how the website behaves.

| Variable                     | Default                  | Example                  | Description |
| ---------------------------- | ------------------------ | ------------------------ | ----------- |
| website_index_document       | `"index.html"`           | `"homepage.html"`        | Filename to use when a URL requests a directory. |
| website_logs_prefix          | `"s3/"`                  | `"example/s3/"`          | Prefix to use when storing S3 logs for the main bucket in a logging bucket **(must end in a "/")**. You can use the same logging bucket for multiple services by changing this prefix. |
| website_error_department     | `null`                   | `"Tech Services"`        | Department to use for the wordmark on error pages. The default is either the first custom domain, or the value `"University of Illinois"`. |
| website_error_headers        | (varies)                 |                          | This is a map of HTTP Status Code to text to display in the header element of the error page. You can override individual header texts by changing this variable. |
| website_error_messages       | (varies)                 |                          | This is a map of HTTP Status Code to text to display in the message element of the error page. Full HTML is allowed here. You can override individual message texts by changing this variable. |
| website_error_contact        | `"consult@illinois.edu"` | `"example@illinois.edu"` | Email address to list as the contact on error pages. |
| website_failover_enabled     | `null`                   | `true`                   | Enable the failover bucket and replication. If `cloudfront_enabled` is true then this will be ignored. |
| website_failover_logs_prefix | `"s3/"`                  | `"example/s3/"`          | Prefix to use when storing S3 logs for the failover bucket in a logging bucket **(must end in a "/")**. You can use the same logging bucket for multiple services by changing this prefix. |
| website_objects              | {}                       | See example              | Map of objects to sync to the website main bucket. This must be a value suitable for `for_each` (known at plan time). |
| website_noncurrent_expire    | `0`                      | `7`                      | Number of days before expiring non-current versions of objects. Set to 0 to not expire. |

#### website_objects

There is an easy way to sync objects from your repository to the static website
using this variable. It is a map where the key is the S3 object key and the
value is an object:

- `source` or `content`: path to a file to upload (`source`) or text to use
  (`content`). One and only one of these can be specified.
- `content_disposition`: control how the content is displayed on the client.
  Almost always used to force the client to download the file instead of
  displaying it. Optional.
- `content_encoding`: allows you to upload content that is GZipped in storage
  but have it decompressed when used as a response to the client. Optional.
- `content_type`: for most keys this can be correctly detected  using the
  extension. However, if you would like to you can override it. Optional.
- `cache_control`: for setting a specific value to override the CloudFront and
  browser default caching behavior. Optional.

**Warning**: because this variable is used in `for_each`, all the keys must be
known at plan time. You can use static values or functions like `fileset()` to
build a map of object keys, but you cannot use any dynamically generated values
for keys.

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

| Variable             | Default | Example                   | Description |
| -------------------- | ------- | ------------------------- | ----------- |
| logs_bucket          | `null`  | `"example-logs"`          | Name of the bucket to store main bucket logs in. If not provided then a new, private bucket will be created. |
| failover_logs_bucket | `null`  | `"example-failover-logs"` | Name of the bucket to store failover bucket logs in. If not provided then a new, private bucket will be created. |
| logs_expire          | `30`    | `90`                      | Number of days to wait before deleting log files. This is only used if `logs_bucket` is not specified. |

## Outputs

The terraform configuration outputs several values for you to use.

| Value             | Description |
| ----------------- | ----------- |
| cloudfront_domain | Domain name of your static website. You can create a CNAME to this in DNS to use custom domains (if configured in `cloudfront_domains`). If you need to create A or AAAA records then you will have to use AWS Route53 with aliases to this domain. |
| website           | The main bucket information: bucket, endpoint, regional_domain_name. |
| website_failover  | The failover bucket information: bucket, endpoint, regional_domain_name. These values are null if no failover site was created. |

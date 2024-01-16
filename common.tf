# =========================================================
# Data
# =========================================================

data "aws_partition" "current" {}

# =========================================================
# Locals
# =========================================================

locals {
    partition = data.aws_partition.current.partition

    name_prefix = coalesce(var.name_prefix, "${var.project}-")

    mimetypes_default = {
        ".txt"    = "text/plain; charset=utf-8"
        ".pdf"    = "application/pdf"
        ".pgp"    = "application/pgp-encrypted"
        ".asc"    = "application/pgp-signature"
        ".sig"    = "application/pgp-signature"
        ".ps"     = "application/postscript"
        ".rdf"    = "application/rdf+xml"
        ".rtf"    = "application/rtf"
        ".rtx"    = "text/richtext"
        ".ppd"    = "application/vnd.cups-ppd"
        ".pcl"    = "application/vnd.hp-pcl"
        ".xps"    = "application/vnd.ms-xpsdocument"
        ".eml"    = "message/rfc822"
        ".mime"   = "message/rfc822"
        ".ics"    = "text/calendar"
        ".csv"    = "text/csv"

        ".doc"    = "application/msword"
        ".dot"    = "application/msword"
        ".xls"    = "application/vnd.ms-excel"
        ".eot"    = "application/vnd.ms-fontobject"
        ".ppt"    = "application/vnd.ms-powerpoint"
        ".pps"    = "application/vnd.ms-powerpoint"
        ".pot"    = "application/vnd.ms-powerpoint"
        ".mpp"    = "application/vnd.ms-project"
        ".mpt"    = "application/vnd.ms-project"
        ".pptx"   = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        ".sldx"   = "application/vnd.openxmlformats-officedocument.presentationml.slide"
        ".ppsx"   = "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
        ".potx"   = "application/vnd.openxmlformats-officedocument.presentationml.template"
        ".xlsx"   = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        ".xltx"   = "application/vnd.openxmlformats-officedocument.spreadsheetml.template"
        ".docx"   = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        ".dotx"   = "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
        ".mdb"    = "application/x-msaccess"
        ".pub"    = "application/x-mspublisher"

        ".odc"    = "application/vnd.oasis.opendocument.chart"
        ".otc"    = "application/vnd.oasis.opendocument.chart-template"
        ".odb"    = "application/vnd.oasis.opendocument.database"
        ".odf"    = "application/vnd.oasis.opendocument.formula"
        ".odft"   = "application/vnd.oasis.opendocument.formula-template"
        ".odg"    = "application/vnd.oasis.opendocument.graphics"
        ".otg"    = "application/vnd.oasis.opendocument.graphics-template"
        ".odi"    = "application/vnd.oasis.opendocument.image"
        ".oti"    = "application/vnd.oasis.opendocument.image-template"
        ".odp"    = "application/vnd.oasis.opendocument.presentation"
        ".otp"    = "application/vnd.oasis.opendocument.presentation-template"
        ".ods"    = "application/vnd.oasis.opendocument.spreadsheet"
        ".ots"    = "application/vnd.oasis.opendocument.spreadsheet-template"
        ".odt"    = "application/vnd.oasis.opendocument.text"
        ".odm"    = "application/vnd.oasis.opendocument.text-master"
        ".ott"    = "application/vnd.oasis.opendocument.text-template"
        ".oth"    = "application/vnd.oasis.opendocument.text-web"
        ".oxt"    = "application/vnd.openofficeorg.extension"

        ".html"   = "text/html; charset=utf-8"
        ".htm"    = "text/html; charset=utf-8"
        ".xhtml"  = "application/xhtml+xml"

        ".css"    = "text/css; charset=utf-8"
        ".js"     = "application/javascript"
        ".mjs"    = "application/javascript"
        ".wasm"   = "application/wasm"

        ".xml"    = "application/xml"
        ".json"   = "application/json"
        ".jsonld" = "application/ld+json"
        ".atom"   = "application/atom+xml"
        ".rss"    = "application/rss+xml"
        ".wsdl"   = "application/wsdl+xml"

        ".gif"    = "image/gif"
        ".jpeg"   = "image/jpeg"
        ".jpg"    = "image/jpeg"
        ".jpe"    = "image/jpeg"
        ".png"    = "image/png"
        ".svg"    = "image/svg+xml"
        ".webp"   = "image/webp"
        ".ico"    = "image/vnd.microsoft.icon"
        ".tiff"   = "image/tiff"
        ".tif"    = "image/tiff"
        ".psd"    = "image/vnd.adobe.photoshop"

        ".weba"   = "audio/webm"
        ".m4a"    = "audio/mp4"
        ".mp4a"   = "audio/mp4"
        ".mpga"   = "audio/mpeg"
        ".mp2"    = "audio/mpeg"
        ".mp2a"   = "audio/mpeg"
        ".mp3"    = "audio/mpeg"
        ".mp3a"   = "audio/mpeg"
        ".oga"    = "audio/ogg"
        ".ogg"    = "audio/ogg"
        ".acc"    = "audio/x-aac"
        ".mka"    = "audio/x-matroska"
        ".m3u"    = "audio/x-mpegurl"
        ".wma"    = "audio/x-ms-wma"
        ".wav"    = "audio/x-wav"

        ".webm"   = "video/webm"
        ".3gp"    = "video/3gpp"
        ".3g2"    = "video/3gpp2"
        ".mp4"    = "video/mp4"
        ".mp4v"   = "video/mp4"
        ".mpg4"   = "video/mp4"
        ".mpeg"   = "video/mpeg"
        ".mpg"    = "video/mpeg"
        ".mpe"    = "video/mpeg"
        ".ogv"    = "video/ogg"
        ".qt"     = "video/quicktime"
        ".mov"    = "video/quicktime"
        ".mxu"    = "video/vnd.mpegurl"
        ".m4u"    = "video/vnd.mpegurl"
        ".m4v"    = "video/x-m4v"
        ".mkv"    = "video/x-matroska"
        ".wmv"    = "video/x-ms-wmv"
        ".avi"    = "video/x-msvideo"

        ".ttf"    = "font/ttf"
        ".otf"    = "font/otf"
        ".eot"    = "application/vnd.ms-fontobject"
        ".woff"   = "font/woff"
        ".woff2"  = "font/woff2"

        ".jar"    = "application/java-archive"
        ".ser"    = "application/java-serialized-object"
        ".class"  = "application/java-vm"

        ".p8"     = "application/pkcs8"
        ".p10"    = "application/pkcs10"
        ".p12"    = "application/pkcs12"
        ".p7m"    = "application/pkcs7-mime"
        ".p7c"    = "application/pkcs7-mime"
        ".p7s"    = "application/pkcs7-signature"
        ".p7b"    = "application/x-pkcs7-certificates"
        ".spc"    = "application/x-pkcs7-certificates"
        ".p7r"    = "application/x-pkcs7-certreqresp"
        ".ac"     = "application/pkix-attr-cert"
        ".cer"    = "application/pkix-cert"
        ".crl"    = "application/pkix-crl"
        ".pki"    = "application/pkixcmp"
        ".pfx"    = "application/x-pkcs12"
        ".p12"    = "application/x-pkcs12"
        ".der"    = "application/x-x509-ca-cert"
        ".crt"    = "application/x-x509-ca-cert"

        ".apk"    = "application/vnd.android.package-archive"
        ".7z"     = "application/x-7z-compressed"
        ".dmg"    = "application/x-apple-diskimage"
        ".bz"     = "application/x-bzip"
        ".bz2"    = "application/x-bzip2"
        ".deb"    = "application/x-debian-package"
        ".rar"    = "application/x-rar-compressed"
        ".tar"    = "application/x-tar"
        ".xz"     = "application/x-xz"
        ".zip"    = "application/zip"
    }
    mimetypes = merge(
        local.mimetypes_default,
        var.mimetypes,
    )
}

# =========================================================
# Data: Assume
# =========================================================

data "aws_iam_policy_document" "assume_s3" {
    statement {
        effect = "Allow"

        actions = [ "sts:AssumeRole" ]

        principals {
            type = "Service"
            identifiers = [ "s3.amazonaws.com" ]
        }
    }
}

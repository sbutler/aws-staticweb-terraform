terraform {
    required_version = "~> 1.6.2"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.13"
        }
        random = {
            source  = "hashicorp/random"
            version = "~> 3.5.1"
        }
        time = {
            source  = "hashicorp/time"
            version = "~> 0.9.1"
        }
    }

    /*
    backend "s3" {
        bucket         = "CHANGEME"
        key            = "CHANGEME"
        dynamodb_table = "terraform"

        encrypt = true
        region = "us-east-2"
    }
    */
}


provider "aws" {
    region = "us-east-2"

    default_tags {
        tags = {
            Service     = var.service
            Contact     = var.contact
            Environment = var.environment

            Project = var.project
        }
    }
}

provider "aws" {
    alias  = "failover"
    region = "us-east-1"

    default_tags {
        tags = {
            Service     = var.service
            Contact     = var.contact
            Environment = var.environment

            Project = var.project
        }
    }
}

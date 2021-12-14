terraform {
    required_version = "~> 1.1.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.69.0"
        }
        random = {
            source  = "hashicorp/random"
            version = "~> 3.1"
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

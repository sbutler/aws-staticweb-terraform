terraform {
    required_version = ">= 1.6.2"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.13"

            configuration_aliases = [ aws.failover ]
        }
        random = {
            source  = "hashicorp/random"
            version = ">= 3.5.1"
        }
        time = {
            source  = "hashicorp/time"
            version = ">= 0.9.1"
        }
    }
}

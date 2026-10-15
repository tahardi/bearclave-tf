terraform {
  required_version = ">= 1.14.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
  backend "gcs" {
    bucket = ""
    prefix = "bootstrap/aws"
  }
}

provider "aws" {
  region = var.aws_region
}

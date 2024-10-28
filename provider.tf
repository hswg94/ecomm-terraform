terraform {
  cloud {
    organization = "computing-project"
    workspaces {
      name = "aws-project-workspace"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.73"
    }
  }
  required_version = ">= 1.9.7"
}

provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

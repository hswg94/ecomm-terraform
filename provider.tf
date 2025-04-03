terraform {
  required_version = ">= 1.10.5"
  cloud {
    organization = "computing-project"
    workspaces {
      name = "aws-project-workspace"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.89"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

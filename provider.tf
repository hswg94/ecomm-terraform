terraform {
  // when upgrading version, first run 'choco upgrade terraform' on OS.
  required_version = ">= 1.12.2"
  cloud {
    organization = "computing-project"
    workspaces {
      name = "aws-project-workspace"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2"
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

/*
Version Constraint Operators:

= or no operator Allows only the exact version specified.
  - Example: = 1.2.3 allows only version 1.2.3

!= Excludes a specific version.
  - Example: != 1.2.3 allows all versions except 1.2.3

>  Allows versions newer than the one specified.
  - Example: > 1.2.3 allows 1.2.4, 1.3.0, 2.0.0, etc.

>= Allows the specified version or newer.
  - Example: >= 1.2.3 allows 1.2.3, 1.2.4, 1.3.0, etc.

<  Allows only versions older than the one specified.
  - Example: < 2.0.0 allows 1.9.9 and below

<= Allows the specified version or older.
  - Example: <= 1.2.3 allows 1.2.3, 1.2.2, etc.

~> Allows only the right-most version component to increment.
  - Example: ~> 1.0.4 allows versions >= 1.0.4 and < 1.1.0
  - Example: ~> 1.1 allows versions >= 1.1.0 and < 2.0.0
*/
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0" # 6.0+ is needed for the per-resource `region` argument
    }
  }
}

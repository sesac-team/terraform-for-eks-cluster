terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.61.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}
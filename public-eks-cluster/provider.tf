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
  }
}

provider "aws" {
  region = "${var.region}"
}

provider "helm" {
    kubernetes {
      host = module.eks.cluster_endpoint
      cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
      exec {
        api_version = "client.authentication.k8s.io/v1"
        args = [ "eks","get-token", "--cluster-name", module.eks.cluster_name ]
        command = "aws"
      }
    }
}
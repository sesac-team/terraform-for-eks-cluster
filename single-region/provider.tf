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
  region = "${var.region}"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

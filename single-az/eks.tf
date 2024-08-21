resource "random_string" "suffix" {
  length  = 8
  special = false # 특수문자를 제외한 8자의 무작위 문자열 생성
}

locals {
  cluster_name = "my-eks-${random_string.suffix.result}"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.30"
  cluster_endpoint_private_access = true  # Basiton server를 통해서만 private subnet의 노드에 접근할 수 있도록

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-ebs-csi-driver     = {}
  }
  
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    eks_nodes = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 2
      max_size     = 5
      desired_size = 3
      key_name = ""
    }
  }
  enable_irsa = true
  enable_cluster_creator_admin_permissions = true
}
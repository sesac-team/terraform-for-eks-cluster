locals {
  cluster_name = "fullaccel-eks"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.28"

  # API 엔드포인트로 접근을 VPC 내 Bastion Server에서만 가능하도록 구성 
  cluster_endpoint_public_access = false

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = [
    element(module.vpc.private_subnets, 0),  
    element(module.vpc.private_subnets, 1)  
  ]
  
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-ebs-csi-driver     = {}
  }
  
  eks_managed_node_groups = {
    eks_nodes = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 5
      desired_size = 3
    }
  }
  enable_irsa = true
  enable_cluster_creator_admin_permissions = true
}

resource "aws_security_group_rule" "allow_bastion_sg" {
  type        = "ingress"
  from_port    = 443
  to_port      = 443
  protocol     = "tcp"
  security_group_id = module.eks.cluster_security_group_id
  source_security_group_id = aws_security_group.bastion_server_sg.id
  description = "add sg of BASTION server"
}
locals {
  cluster_name = "fullaccel-eks"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.28"

  # 외부 인터넷망에서도 EKS 클러스터의 API 엔드포인트로 접근 가능
  cluster_endpoint_public_access = true

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
    aws-efs-csi-driver     = {
      service_account_role_arn = module.efs_csi_irsa.iam_role_arn
    }
  }
  
  eks_managed_node_groups = {
    eks-nodes = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.large"]

      min_size     = 2
      max_size     = 5
      desired_size = 3
    }
  }
  enable_irsa = true
  enable_cluster_creator_admin_permissions = true
}

# BASTION 서버의 보안그룹 허용 인바운드 규칙 추가
resource "aws_security_group_rule" "allow_bastion_sg" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = aws_security_group.bastion_server_sg.id
  description              = "add sg of BASTION server"
}

# istio 동작 허용 인바운드 규칙 추가
resource "aws_security_group_rule" "allow_istio" {
  type              = "ingress"
  from_port         = 15012
  to_port           = 15017
  protocol          = "tcp"
  security_group_id = module.eks.cluster_security_group_id
  description       = "add sg for ISTIO pod"
  cidr_blocks       = ["0.0.0.0/0"]
}

# EFS 보안그룹 허용 인바운드 규칙 추가
resource "aws_security_group_rule" "allow_efs_sg" {
  type                      = "ingress"
  from_port                 = 2049
  to_port                   = 2049
  protocol                  = "tcp"
  security_group_id         = module.eks.cluster_security_group_id
  source_security_group_id  = aws_security_group.efs_sg.id
}

# 현재 시스템에 aws 자격증명이 있을 경우에만 명령어 실행 성공(BASTION 서버에선 자격증명부터 등록 필요)
resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}
    EOT
  }

  depends_on = [module.eks]
}
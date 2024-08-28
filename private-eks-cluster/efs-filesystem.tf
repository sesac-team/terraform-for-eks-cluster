# EKS 클러스터의 서비스 어카운트와 EFS CSI 드라이버 IAM 역할 바인딩
module "efs_csi_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${module.eks.cluster_name}-efs-csi"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}

# EFS 파일 시스템 생성
resource "aws_efs_file_system" "efs" {
  creation_token = "eks-efs"
  tags = {
    Name = "eks-efs"
  }
}

# EFS 마운트 대상 생성
resource "aws_efs_mount_target" "efs_mount_target" {
  count = length(module.vpc.azs) # 가용 영역 수에 따라 EFS 마운트 대상 생성

  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = element(module.vpc.private_subnets, count.index)
  security_groups = ["${aws_security_group.efs_sg.id}"]
}

# EFS 보안 그룹 생성
resource "aws_security_group" "efs_sg" {
  name        = "allow nfs for efs"
  description = "add sg for EFS file system"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs_sg"
  }
}
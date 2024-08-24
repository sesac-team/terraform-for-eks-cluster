locals {
  lb_controller_iam_role_name        = "AmazonEKSLoadBalancerControllerRole"
  lb_controller_service_account_name = "aws-load-balancer-controller"
}

# 현재 EKS 클러스터의 auth 조회
data "aws_eks_cluster_auth" "this" {
  name = local.cluster_name
}

# IAM 모듈 사용해 IAM 역할 생성
module "lb_controller_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true

  role_name        = local.lb_controller_iam_role_name
  role_path        = "/"
  role_description = "role of AWS Load Balancer Controller for EKS"

  # OIDC url 
  provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  
  # 서비스 어카운트와 IAM 역할을 바인딩
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:${local.lb_controller_service_account_name}"
  ]

  # IAM 역할과 sts를 바인딩
  oidc_fully_qualified_audiences = [
    "sts.amazonaws.com"
  ]
}

# LBC에 필요한 IAM 정책(policy) json 파일 사용
data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.0/docs/install/iam_policy.json"
}

# IAM 정책(policy) 생성 및 역할과 바인딩
resource "aws_iam_role_policy" "controller" {
  name_prefix = "AWSLoadBalancerControllerIAMPolicy"
  policy      = data.http.iam_policy.body
  role        = module.lb_controller_role.iam_role_name
}

# Helm 차트 배포
resource "helm_release" "release" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"

  values = [
    <<EOF
    {
      clusterName : module.eks.cluster_id,
      serviceAccount.create      : false,
      serviceAccount.name       : local.lb_controller_service_account_name
    }
    EOF
  ]
}
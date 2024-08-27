# AWS Load Balancer Controller가 OIDC를 통해 IAM 역할을 승계
data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    #  OIDC 공급자의 ARN을 주체로 설정
    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

# AWS Load Balancer Controller의 IAM 역할 생성
resource "aws_iam_role" "aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
  name = "aws-load-balancer-controller"
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
    policy = file("./AWSLoadBalancerControllerRole.json")
    name = "AWSLoadBalancerControllerRole"
}
# IAM 역할과 정책을 바인딩
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
    role = aws_iam_role.aws_load_balancer_controller.name
    policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

# helm을 사용해 AWS Load Balancer Controller를 EKS 클러스터에 배포
resource "helm_release" "aws-load-balancer-controller" {
    name = "aws-load-balancer-controller"

    repository = "https://aws.github.io/eks-charts"
    chart = "aws-load-balancer-controller"
    namespace = "kube-system"
    version = "1.5.5"

    set {
      name = "clusterName"
      value = module.eks.cluster_name
    }
    set {
      name = "image.tag"
      value = "v2.5.1"
    }
    set {
      name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.aws_load_balancer_controller.arn
    }
  set {
    name  = "aws.region"
    value = var.region 
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

    depends_on = [ 
        module.eks.eks_nodes,
        aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
     ]
}


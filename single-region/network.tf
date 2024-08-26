module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "fullaccel-vpc"
  cidr = "10.0.0.0/16"
  azs             = ["${var.region}a", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  public_subnets  = ["10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = true

  # internal-elb 프라이빗 로드 밸런서로 VPC 내에서만 서비스를 노출
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
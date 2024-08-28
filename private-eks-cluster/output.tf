# EFS 파일 시스템 ID 출력
output "efs_file_system_id" {
  value = aws_efs_file_system.efs.id
}

# OIDC 공급자의 ARN 출력
output "OIDC_provider_arn" {
  value = module.eks.oidc_provider_arn
}

# 자동으로 실행되는 update config 명령어 출력
output "kubeconfig_command " {
  description = "Automatically Generated update-kubeconfig Command"
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
# 자동으로 실행되는 update config 명령어 출력
output "configure_kubectl" {
  description = "Automatically Generated update-kubeconfig Command"
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
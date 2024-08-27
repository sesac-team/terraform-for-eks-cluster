output "configure_kubectl" {
  value = <<EOF
    aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}
    EOF
}
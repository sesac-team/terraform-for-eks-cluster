resource "helm_release" "metrics-server" {
  depends_on = [
    module.eks
  ]

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = ">= 3.12.0"
}
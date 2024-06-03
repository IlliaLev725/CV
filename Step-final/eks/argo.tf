

resource "helm_release" "argocd" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "6.7.18"
  namespace  = "argocd"
  values     = [file("value.yaml")]
}



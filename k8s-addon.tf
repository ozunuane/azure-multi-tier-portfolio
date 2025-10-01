# resource "helm_release" "cert_manager" {
#   name = "cert-manager"

#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"
#   namespace        = var.env
#   create_namespace = true
#   version          = "v1.13.1"

#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
# }


# data "azurerm_kubernetes_cluster" "this" {
#   name                = azurerm_kubernetes_cluster.privateaks.name
#   resource_group_name = azurerm_kubernetes_cluster.privateaks.resource_group_name

#   # Comment this out if you get: Error: Kubernetes cluster unreachable 
#   #   depends_on = [azurerm_kubernetes_cluster.privateaks]
# }

# provider "helm" {
#   kubernetes {
#     host                   = data.azurerm_kubernetes_cluster.this.kube_config.0.host
#     client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_certificate)
#     client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_key)
#     cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate)
#   }
# }



# ### HELM NGINX EXTERNAL  ###
# resource "helm_release" "external_nginx" {
#   count            = terraform.workspace == "production" || terraform.workspace == "staging" ? 1 : 0
#   name             = "external-nginx-${terraform.workspace}"
#   repository       = "https://kubernetes.github.io/ingress-nginx"
#   chart            = "ingress-nginx"
#   namespace        = var.env
#   create_namespace = true
#   version          = "4.8.0"

#   values = [file("${path.module}/values/ingress/ingress.yaml")]
# }
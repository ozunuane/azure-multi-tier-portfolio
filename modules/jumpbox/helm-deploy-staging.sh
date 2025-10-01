#!/bin/bash

# # Exit on any error
# set -e
# # Variables
# NAMESPACE=${1:-default}  # Pass namespace as the first argument, default to "default"
# CERT_MANAGER_NAMESPACE="cert-manager"
# HELM_VERSION="v3.13.0"
# NGINX_INGRESS_RELEASE_NAME_EXTERNAL="ingress-external"
# NGINX_INGRESS_RELEASE_NAME_INTERNAL="ingress-internal"
# CERT_MANAGER_RELEASE_NAME="cert-manager"
# CONTEXT="private-aks"

# # Update and install Helm
# echo "⌛ Installing Helm..."
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# chmod 700 get_helm.sh
# ./get_helm.sh --version $HELM_VERSION

# # Verify Helm installation
# helm version || { echo "❌ Helm installation failed"; exit 1; }

# export KUBECONFIG="/home/azureuser/.kube/config.yml"
# sudo kubectl config use-context $CONTEXT 
# alias kubectl='kubectl --kubeconfig /home/azureuser/.kube/config.yml'
# kubectl cluster-info


# # # Add Helm repositories
# # echo "⌛ Adding Helm repositories..."
# # helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# # helm repo update


# # Install Cert-Manager
# echo "⌛ Installing Cert-Manager..."
# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.1.1/cert-manager.yaml

# # kubectl apply -f - <<EOF
# # apiVersion: cert-manager.io/v1
# # kind: ClusterIssuer
# # metadata:
# #   name: letsencrypt-staging
# # spec:
# #   acme:
# #     server: https://acme-v02.api.letsencrypt.org/directory   

# #     email: ozunuane@gmail.com
# #     privateKeySecretRef:
# #       name: letsencrypt-staging
# #     solvers:
# #     - http01:
# #         ingress:
# #           class: ingress-external 
# # EOF


# # # Install NGINX Ingress Controller an external
# # echo "⌛ Installing NGINX Ingress Controller..."
# # kubectl create namespace $NAMESPACE || true
# # helm upgrade --install $NGINX_INGRESS_RELEASE_NAME ingress-nginx/ingress-nginx \
# #   --namespace $NAMESPACE \
# #   --set controller.replicaCount=2 \


# # Verify NGINX Ingress installation
# kubectl rollout status deployment/$NGINX_INGRESS_RELEASE_NAME_EXTERNAL-controller -n $NAMESPACE || { echo "❌ NGINX external Ingress installation failed"; exit 1; }
# # kubectl rollout status deployment/$NGINX_INGRESS_RELEASE_NAME_INTERNAL-controller -n $NAMESPACE || { echo "❌ NGINX internal Ingress installation failed"; exit 1; }

# # Verify Cert-Manager installation
# kubectl rollout status deployment/cert-manager -n $CERT_MANAGER_NAMESPACE || { echo "❌ Cert-Manager installation failed"; exit 1; }





# # echo "✅ Helm, Cert-Manager, and NGINX Ingress have been successfully installed."
# echo "✅ Helm, Cert-Manager, and NGINX Ingress have been Commented out"



set -e
# # Variables
NAMESPACE=${1:-default}  # Pass namespace as the first argument, default to "default"
CERT_MANAGER_NAMESPACE="cert-manager"
HELM_VERSION="v3.13.0"
# NGINX_INGRESS_RELEASE_NAME_EXTERNAL="ingress-external"
# NGINX_INGRESS_RELEASE_NAME_INTERNAL="ingress-internal"
CERT_MANAGER_RELEASE_NAME="cert-manager"
CONTEXT="private-aks"

# Update and install Helm
echo "⌛ Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh --version $HELM_VERSION

# Verify Helm installation
helm version || { echo "❌ Helm installation failed"; exit 1; }

export KUBECONFIG="/home/azureuser/.kube/config.yml"
sudo kubectl config use-context $CONTEXT 
alias kubectl='kubectl --kubeconfig /home/azureuser/.kube/config.yml'
kubectl cluster-info

# Add Helm repositories
echo "⌛ Adding Helm repositories..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install Cert-Manager
echo "⌛ Installing Cert-Manager..."
kubectl create namespace $CERT_MANAGER_NAMESPACE || true
helm upgrade --install $CERT_MANAGER_RELEASE_NAME jetstack/cert-manager \
  --namespace $CERT_MANAGER_NAMESPACE \
  --set installCRDs=true \
  --set global.leaderElection.namespace=$CERT_MANAGER_NAMESPACE

"echo '⌛️ Updating kubectl config...'",

# Update dependencies
"echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
"curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",

"sudo apt-get update --allow-insecure-repositories",
"sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",

# Install kubectl for x86_64
"curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
"curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256",
"echo \"$(cat kubectl.sha256)  kubectl\" | sha256sum --check",
"sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",

# Install Kustomize
"curl -sfLo kustomize https://github.com/kubernetes-sigs/kustomize/releases/download/v3.1.0/kustomize_3.1.0_linux_amd64",
"chmod u+x ./kustomize",
"curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"


# Configure kubectl contexts
"kubectl create namespace ${var.env}"
"alias kubectl='kubectl --kubeconfig /home/{var.vm_user}}/config.yml'",
"kubectl config use-context internal --namespace=${var.env}",
"kubectl cluster-info",

"echo '✅ Updated kubectl config.'"




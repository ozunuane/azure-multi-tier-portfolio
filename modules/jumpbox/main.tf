resource "azurerm_public_ip" "pip" {
  name                = "vm-pip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_network_security_group" "vm_sg" {
  name                = "vm-sg"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}





# resource "azurerm_network_security_group" "vm_sg_http" {
#   name                = "vm-sg"
#   location            = var.location
#   resource_group_name = var.resource_group
#   tags                = var.tags
#   security_rule {
#     name                       = "SSH"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }





# resource "azurerm_network_security_group" "vm_sg_https" {
#   name                = "vm-sg"
#   location            = var.location
#   resource_group_name = var.resource_group
#   tags                = var.tags
#   security_rule {
#     name                       = "SSH"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "443"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }


resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
  ip_configuration {
    name                          = "vmNicConfiguration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "sg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_sg.id

}

resource "random_password" "adminpassword" {
  keepers = {
    resource_group = var.resource_group
  }
  length      = 8
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
}





# resource "azurerm_key_vault_secret" "adminpassword_secret" {
#   name         = "${var.env}BastionAdminPassword"
#   value        = random_password.adminpassword.result
#   key_vault_id = var.key_vault_id

#   lifecycle {
#     ignore_changes = [value] # Prevents overwriting on each apply
#   }
# }


resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                            = "bastion"
  location                        = var.location
  resource_group_name             = var.resource_group
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]
  size                            = var.size
  computer_name                   = "jumpboxvm"
  admin_username                  = var.vm_user
  admin_password                  = random_password.adminpassword.result
  disable_password_authentication = false
  tags                            = var.tags

  os_disk {
    name                 = "jumpboxOsDisk"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }



  provisioner "remote-exec" {
    connection {
      host     = self.public_ip_address
      type     = "ssh"
      user     = var.vm_user
      password = random_password.adminpassword.result
    }
    inline = [
      "echo '⌛️ Updating kubectl config...'",

      # Update dependencies
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",

      "sudo apt-get update --allow-insecure-repositories",



      # Install kubectl for x86_64
      "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
      "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256",
      "echo \"$(cat kubectl.sha256)  kubectl\" | sha256sum --check",
      "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",

      # Install Kustomize
      "curl -sfLo kustomize https://github.com/kubernetes-sigs/kustomize/releases/download/v3.1.0/kustomize_3.1.0_linux_amd64",
      "chmod u+x ./kustomize",

      # Install Azure CLI
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",


      # Configure kubectl contexts
      "kubectl create namespace ${var.env}",
      "alias kubectl='kubectl --kubeconfig /home/${var.vm_user}/.kube/config.yml'",
      "kubectl config set-context --current --namespace=${var.env}",
      "kubectl cluster-info",

      "echo '✅ Updated kubectl config.'",


    ]



  }

}



resource "null_resource" "install" {
  triggers = {
    on_creation           = azurerm_linux_virtual_machine.jumpbox.id
    instance_attr_changes = azurerm_linux_virtual_machine.jumpbox.id
  }
}


resource "null_resource" "update" {
  triggers = {
    server  = azurerm_linux_virtual_machine.jumpbox.id
    install = null_resource.install.id
    # always_run = timestamp() # Current timestamp ensures it always runs

  }


  connection {
    host     = azurerm_linux_virtual_machine.jumpbox.public_ip_address
    type     = "ssh"
    user     = var.vm_user
    password = random_password.adminpassword.result
  }


  provisioner "remote-exec" {
    inline = [
      "directory=.kube",
      "config_file=\"$directory/config.yml\"",
      "if [ -d \"$directory\" ]; then",
      "  echo \"Directory '$directory' already exists.\"",
      "  sudo rm -rf \"$directory\"",
      "  echo \"Directory '$directory' and its contents deleted successfully.\"",
      "fi",
      "sudo mkdir -p \"$directory\"",
      "echo \"Directory '$directory' created successfully.\"",
      "sudo touch \"$config_file\"",
      "echo \"File '$config_file' created successfully.\"",
      "sudo chown ${var.vm_user}:${var.vm_user} /home/${var.vm_user}/.kube/config.yml ",
      "sudo chmod 600 /home/${var.vm_user}/.kube/config.yml "

    ]
  }


  # update service account credential file
  provisioner "file" {
    content     = var.kube_config_raw
    destination = "/home/${var.vm_user}/.kube/config.yml"

  }
}






####### HELM SETUP STAGING  ###

###### copy helm script  to vm ###
resource "null_resource" "helm_script_staging" {
  count = terraform.workspace == "staging" ? 1 : 0
  triggers = {
    on_creation = azurerm_linux_virtual_machine.jumpbox.id
    # instance_attr_changes = azurerm_linux_virtual_machine.jumpbox.id
    # always_run = timestamp() # Current timestamp ensures it always runs

  }

  connection {
    host     = azurerm_linux_virtual_machine.jumpbox.public_ip_address
    type     = "ssh"
    user     = var.vm_user
    password = random_password.adminpassword.result

  }
  provisioner "file" {
    source      = "${path.module}/helm-deploy-staging.sh"
    destination = "/home/${var.vm_user}/helm-deploy-staging.sh"
  }
}



###### HELM DEPLOY NGINX INGRESS AND CERT MANAGER 
resource "null_resource" "helm_deploy_staging" {
  count = terraform.workspace == "staging" ? 1 : 0
  triggers = {
    on_creation = azurerm_linux_virtual_machine.jumpbox.id
    # instance_attr_changes = azurerm_linux_virtual_machine.jumpbox.id
    # always_run = timestamp() # Current timestamp ensures it always runs

  }

  connection {
    host     = azurerm_linux_virtual_machine.jumpbox.public_ip_address
    type     = "ssh"
    user     = var.vm_user
    password = random_password.adminpassword.result

  }

  provisioner "remote-exec" {
    inline = [
      "alias kubectl='kubectl --kubeconfig /home/${var.vm_user}/.kube/config.yml'",
      "kubectl config use-context private-aks --namespace=${var.env}",
      "kubectl cluster-info",
      # "sudo chmod +x /home/${var.vm_user}/helm-deploy-staging.sh",
      # "sudo bash /home/${var.vm_user}/helm-deploy-staging.sh ${var.env}",
      "kubectl get pods -n ${var.env}",
      "kubectl get pods -n ${var.env}"
    ]
  }

  depends_on = [null_resource.helm_script_staging]
}












####### HELM SETUP PROD  ###

###### copy helm script  to vm ###
resource "null_resource" "helm_script_prod" {
  count = terraform.workspace == "production" ? 1 : 0
  triggers = {
    on_creation = azurerm_linux_virtual_machine.jumpbox.id
    # instance_attr_changes = azurerm_linux_virtual_machine.jumpbox.id
    # always_run = timestamp() # Current timestamp ensures it always runs

  }

  connection {
    host     = azurerm_linux_virtual_machine.jumpbox.public_ip_address
    type     = "ssh"
    user     = var.vm_user
    password = random_password.adminpassword.result

  }


  provisioner "file" {
    source      = "${path.module}/helm-deploy-production.sh"
    destination = "/home/${var.vm_user}/helm-deploy-production.sh"
  }
}


###### HELM DEPLOY NGINX INGRESS AND CERT MANAGER 
resource "null_resource" "helm_deploy_prod" {
  count = terraform.workspace == "production" ? 1 : 0
  triggers = {
    on_creation = azurerm_linux_virtual_machine.jumpbox.id
    # instance_attr_changes = azurerm_linux_virtual_machine.jumpbox.id
    # always_run = timestamp() # Current timestamp ensures it always runs

  }

  connection {
    host     = azurerm_linux_virtual_machine.jumpbox.public_ip_address
    type     = "ssh"
    user     = var.vm_user
    password = random_password.adminpassword.result

  }


  provisioner "remote-exec" {
    inline = [

      "alias kubectl='kubectl --kubeconfig /home/${var.vm_user}/.kube/config.yml'",
      "kubectl config set-context private-aks--namespace=${var.env}",
      "kubectl cluster-info",
      # "sudo chmod +x /home/${var.vm_user}/helm-deploy-production.sh",
      # "sudo bash /home/${var.vm_user}/helm-deploy-production.sh ${var.env}",
      "kubectl get pods -n ${var.env}",
      "kubectl get pods -n ${var.env}"

    ]


  }
  depends_on = [null_resource.helm_script_prod]
}





resource "azurerm_private_dns_zone_virtual_network_link" "hublink" {
  name                  = "hubnetdnsconfig"
  resource_group_name   = var.dns_zone_resource_group
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}
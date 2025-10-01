resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = { for subnet in var.subnets : subnet.name => subnet.address_prefixes }

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value

}


locals {
  kubevnet_start_ip = cidrhost(var.kube_address_space_string, 1)
  vnet_start_ip     = cidrhost(var.vnet_address_space_string, 1)
}







# resource "azurerm_network_security_group" "postgress" {
#   name                = "postgress"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = var.tags


#   security_rule {
#     name                       = "PostgressDB_5432_spokevnet"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "5432"
#     destination_port_range     = "5432"
#     source_address_prefix      = "*"
#     destination_address_prefix = local.kubevnet_start_ip
#   }

#   security_rule {
#     name                       = "PostgressDB_5432_hubvnet"
#     priority                   = 1004
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "5432"
#     source_address_prefix      = "*"
#     destination_address_prefix = local.kubevnet_start_ip
#   }

#   security_rule {
#     name                       = "Redis_SPOKE_6379"
#     priority                   = 1002
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "6379"
#     source_address_prefix      = "*"
#     destination_address_prefix = local.kubevnet_start_ip
#   }

#   security_rule {
#     name                       = "Redis_HUB_6379"
#     priority                   = 1005
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "6379"
#     source_address_prefix      = "*"
#     destination_address_prefix = local.vnet_start_ip
#   }



#   security_rule {
#     name                       = "HTTPS_443"
#     priority                   = 1003
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "443"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }


#   security_rule {
#     name                       = "HTTPS_80"
#     priority                   = 1006
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "OUT_BOUND"
#     priority                   = 1007
#     direction                  = "Outbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#   # lifecycle {
#   #   ignore_changes = all
#   # }
# }


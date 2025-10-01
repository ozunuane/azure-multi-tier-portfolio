####### VPN GATEWAY SETUP #####
resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  count = 0
  # count               = terraform.workspace == "production" ? 1 : 0
  name                = "${var.env}-vpn-gateway"
  location            = var.location
  resource_group_name = azurerm_resource_group.kube.name
  type                = "Vpn"
  vpn_type            = "RouteBased"

  sku = "VpnGw1"

  ip_configuration {
    name                          = "vpn-gateway-ip-config"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway[0].id
  }
  tags = local.common_tags
}

resource "azurerm_public_ip" "vpn_gateway" {
  count = 0
  # count               = terraform.workspace == "production" ? 1 : 0
  name                = "vpn-gateway-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.kube.name
  allocation_method   = "Dynamic"
  tags                = local.common_tags
}

resource "azurerm_subnet" "gateway" {
  count = 0
  # count                = terraform.workspace == "production" ? 1 : 0
  name                 = "VpnGatewaySubnet"
  resource_group_name  = var.kube_resource_group_name
  virtual_network_name = module.kube_network.vnet_name
  address_prefixes     = var.vpn_subnet_address_space

}


#### VPN PROD CONNECTION ####
resource "azurerm_virtual_network_gateway_connection" "onpremises" {
  count = 0
  # count                      = terraform.workspace == "production" ? 1 : 0
  name                       = "zaho-onprem-vpn-connection"
  location                   = azurerm_resource_group.kube.location
  resource_group_name        = azurerm_resource_group.kube.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway[0].id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem[0].id
  shared_key                 = var.vpn_preshared_key
  tags                       = local.common_tags
}

resource "azurerm_local_network_gateway" "onprem" {
  count = 0
  # count               = terraform.workspace == "production" ? 1 : 0
  name                = "zaho-onpremises-gateway"
  location            = azurerm_resource_group.kube.location
  resource_group_name = azurerm_resource_group.kube.name
  gateway_address     = var.vpn_gateway_address      # on-premises VPN device's public IP
  address_space       = var.vpn_subnet_address_space #  on-premises network's address space
  tags                = local.common_tags
}



# VPN ROUTES to VPN #
resource "azurerm_route_table" "vpn" {
  count = 0
  # count               = terraform.workspace == "production" ? 1 : 0
  name                = "vpn-route-table"
  location            = var.location
  resource_group_name = azurerm_resource_group.kube.name
}

resource "azurerm_route" "vpn_onpremise" {
  count = 0
  # count               = terraform.workspace == "production" ? 1 : 0
  name                = "onpremises-route"
  resource_group_name = azurerm_resource_group.kube.name
  route_table_name    = azurerm_route_table.vpn[0].name
  address_prefix      = var.vpn_local_onprem_address_space # Replace with your on-premises network's address space
  next_hop_type       = "VirtualNetworkGateway"
}

resource "azurerm_subnet_route_table_association" "onprem" {
  count = 0
  # count               = terraform.workspace == "production" ? 1 : 0
  subnet_id      = module.kube_network.subnet_ids["aks-subnet"]
  route_table_id = azurerm_route_table.vpn[0].id
}
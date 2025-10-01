# #### PROD ####
resource "azurerm_public_ip" "prod" {
  count               = terraform.workspace == "production" ? 1 : 0
  name                = "api-gw-${var.env}-pip"
  resource_group_name = var.vnet_resource_group_name
  location            = azurerm_resource_group.vnet.location
  allocation_method   = "Static"
  tags = merge(
    local.common_tags,
    {
      "instance-tag" = "${var.env}-api-pip" # Replace 'your_value_here' with the appropriate value for the tag
    }
  )
}

resource "azurerm_application_gateway" "production" {
  count               = terraform.workspace == "production" ? 1 : 0
  name                = "${var.env}-zaho-appgateway"
  resource_group_name = var.vnet_resource_group_name
  location            = var.location

  sku {
    name     = var.apigateway_sku
    tier     = var.apigateway_tier
    capacity = var.apigateway_capacity
  }

  gateway_ip_configuration {
    name      = "${var.env}-gateway-ip-configuration"
    subnet_id = module.hub_network.subnet_ids["api-gw-subnet"]
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name = local.frontend_ip_configuration_name
    # private_ip_address            = var.apigateway_private_ip_address
    # private_ip_address_allocation = "Static"

    public_ip_address_id = azurerm_public_ip.prod[0].id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    # probe_name            = "app-health-probe"
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  # rewrite_rule_set {
  #   name = azurerm_application_gateway_rewrite_rule_set.security_headers.name
  #   id   = azurerm_application_gateway_rewrite_rule_set.security_headers.id
  # }



  tags = merge(
    local.common_tags,
    {
      "instance-tag" = "${var.env}-api-mgt" # Replace 'your_value_here' with the appropriate value for the tag
    }
  )

  lifecycle {
    ignore_changes = all
  }
  #### warning lifecycle clears all saved ingress configurations by kubernetes ingress
}



resource "azurerm_route_table" "prod" {
  count               = terraform.workspace == "production" ? 1 : 0
  name                = "apinetfw_fw_rt"
  resource_group_name = azurerm_resource_group.vnet.name
  location            = azurerm_resource_group.vnet.location

  route {
    name           = "internet-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet" # Ensure this is set to Internet
  }
}






##### SECURITY GROUP TO DENY PUBLIC IP  ACCESS FROM 80 and 443 ######
# Create the Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg_appgw" {
  count               = terraform.workspace == "production" ? 1 : 0
  name                = "${var.env}-nsg-rg"
  location            = var.location
  resource_group_name = var.vnet_resource_group_name

  security_rule {
    name                       = "${var.env}-allow-appgw-ports"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "65200-65535" # Allow traffic on these ports
    source_address_prefix      = "*"           # Allow traffic from any source
    destination_address_prefix = "*"
  }

  # Rule to allow inbound traffic on HTTP (port 80)
  security_rule {
    name                       = "${var.env}-deny-http"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80" # Allow HTTP traffic
    source_address_prefix      = azurerm_public_ip.prod[0].ip_address
    destination_address_prefix = azurerm_public_ip.prod[0].ip_address
  }

  # Rule to deny inbound traffic on HTTPS (port 443) for public ip 
  security_rule {
    name                       = "${var.env}-deny-https"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443" # Allow HTTPS traffic
    source_address_prefix      = azurerm_public_ip.prod[0].ip_address
    destination_address_prefix = azurerm_public_ip.prod[0].ip_address
  }

  tags = local.common_tags
}


# # Associate the NSG with the Subnet
# resource "azurerm_subnet_network_security_group_association" "nsg_appgw" {
#   count                     = terraform.workspace == "production" ? 0 : 0
#   subnet_id                 = module.hub_network.subnet_ids["api-gw-subnet"]
#   network_security_group_id = azurerm_network_security_group.nsg_appgw[0].id
# }











# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${module.hub_network.vnet_name}-beap"
  frontend_port_name             = "${module.hub_network.vnet_name}-feport"
  frontend_ip_configuration_name = "${module.hub_network.vnet_name}-feip"
  http_setting_name              = "${module.hub_network.vnet_name}-be-htst"
  listener_name                  = "${module.hub_network.vnet_name}-httplstn"
  request_routing_rule_name      = "${module.hub_network.vnet_name}-rqrt"
  redirect_configuration_name    = "${module.hub_network.vnet_name}-rdrcfg"
}


#### STAGING ####
resource "azurerm_public_ip" "example" {
  count               = terraform.workspace == "staging" ? 1 : 0
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

resource "azurerm_application_gateway" "network" {
  count               = terraform.workspace == "staging" ? 1 : 0
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
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example[0].id
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


resource "azurerm_route_table" "example" {
  count               = terraform.workspace == "staging" ? 1 : 0
  name                = "apinetfw_fw_rt"
  resource_group_name = azurerm_resource_group.vnet.name
  location            = azurerm_resource_group.vnet.location

  route {
    name           = "internet-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet" # Ensure this is set to Internet
  }
}














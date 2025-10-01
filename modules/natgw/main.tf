
resource "azurerm_public_ip" "pip" {
  name                = "${var.env}-nat-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
  zones               = ["1"] # Match with NAT Gateway

}

resource "azurerm_nat_gateway" "this" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
  tags                    = var.tags

}


resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = var.subnet_id
  nat_gateway_id = azurerm_nat_gateway.this.id

}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.pip.id
}






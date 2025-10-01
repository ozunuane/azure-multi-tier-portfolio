# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "this" {
  name                          = var.redis_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  capacity                      = var.capacity
  family                        = var.family
  sku_name                      = var.sku_name
  non_ssl_port_enabled          = true
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.public_network_access_enabled
  redis_version                 = var.redis_version
  subnet_id                     = var.subnet_id

  redis_configuration {

  }
}

resource "azurerm_redis_firewall_rule" "this" {
  name                = "${var.env}_redis_firewall"
  redis_cache_name    = azurerm_redis_cache.this.name
  resource_group_name = var.resource_group_name
  start_ip            = "0.0.0.0"         # Start of IPv4 range
  end_ip              = "255.255.255.255" # End of IPv4 range
}


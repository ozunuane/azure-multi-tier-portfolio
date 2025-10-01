resource "azurerm_dns_zone" "public" {
  for_each            = toset(var.domain_names)
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}



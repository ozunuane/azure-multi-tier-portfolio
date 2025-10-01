resource "azurerm_private_dns_a_record" "this" {
  for_each            = toset(var.zone_emple_record_names)
  name                = each.value
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = ["${var.private_ip}"] # Private IP address of the resource
}
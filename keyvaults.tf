# #### STAGING CLOUDFLARE RECORDS ####
# module "A_records" {
#   source             = "./modules/cloudflare/records"
#   domains            = var.domain_names
#   cloudflare_zone_id = var.cloudflare_zone_id
#   type               = "A"
#   ### ELB IP ADDRESS ##
#   ip_address = "203.123.82.132"
# }

# Create an Azure Key Vault
resource "azurerm_key_vault" "keyvault" {
  count                     = terraform.workspace == "staging" ? 1 : 0
  name                      = "${var.env}-zaho-keyvault"
  location                  = var.location
  resource_group_name       = var.kube_resource_group_name
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
}


resource "azurerm_key_vault" "prod_keyvault" {
  count                     = terraform.workspace == "production" ? 1 : 0
  name                      = "${var.env}-zaho-kv"
  location                  = var.location
  resource_group_name       = var.kube_resource_group_name
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
}

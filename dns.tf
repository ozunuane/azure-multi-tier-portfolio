# #### STAGING CLOUDFLARE RECORDS ####
# module "A_records" {
#   source             = "./modules/cloudflare/records"
#   domains            = var.domain_names
#   cloudflare_zone_id = var.cloudflare_zone_id
#   type               = "A"
#   ### ELB IP ADDRESS ##
#   ip_address = "203.123.82.132"
# }

######################################
#######  PUBLIC HOSTED ZONE ##########
######################################

############### STAGING ##############
module "dns_staging_public_zone" {
  count               = terraform.workspace == "staging" ? 1 : 0
  source              = "./modules/dns"
  resource_group_name = azurerm_resource_group.vnet.name
  domain_names        = var.domain_names
  tags                = local.common_tags
}




########## DNS RECORDS ################
######## Staging Record Sets ##########
module "staging_record_sets" {
  count                  = terraform.workspace == "staging" ? 1 : 0
  source                 = "./modules/dns-records"
  resource_group_name    = var.vnet_resource_group_name
  target_resource_id     = azurerm_public_ip.example[0].id
  zone_name              = var.domain_names[0]
  zone_zaho_record_names = var.zone_zaho_record_names
  tags                   = local.common_tags

  # depends_on = [module.dns_staging_public_zone]
}







######################################
#######  PRIVATE HOSTED ZONE PRODUCTION 
######################################


module "dns_prod_private_zone" {
  count               = terraform.workspace == "production" ? 1 : 0
  source              = "./modules/private_dns "
  resource_group_name = azurerm_resource_group.vnet.name
  domain_names        = var.domain_names
  tags                = local.common_tags
  vnet_id             = module.hub_network.vnet_id
}


########## DNS RECORDS ################
######## Prod Record Sets ##########
module "prod_record_sets" {
  count                  = terraform.workspace == "production" ? 1 : 0
  source                 = "./modules/private-dns-records"
  resource_group_name    = var.vnet_resource_group_name
  target_resource_id     = azurerm_application_gateway.production[0].id
  zone_name              = var.domain_names[0]
  zone_zaho_record_names = var.zone_zaho_record_names
  tags                   = local.common_tags
  private_ip             = var.apigateway_private_ip_address
  #   private_ip              = azurerm_application_gateway.production[0].private_ip_address



  depends_on = [module.dns_prod_private_zone]
}






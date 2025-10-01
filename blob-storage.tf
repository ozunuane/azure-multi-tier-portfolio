### PUBLIC ###
## access level set = container
module "private_storage" {
  source                   = "./modules/blob-storage"
  resource_group_name      = var.vnet_resource_group_name
  location                 = var.location
  storage_account_name     = var.private_storage_account_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  containers               = var.private_containers
  use_private_access       = false
  env                      = var.env
}



# module "public_storage" {
#   source                   = "./modules/blob-storage"
#   resource_group_name      = var.vnet_resource_group_name
#   location                 = var.location
#   storage_account_name     = var.storage_account_name
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   min_tls_version          = "TLS1_2"
#   containers               = var.public_containers
#   use_private_access       = false
#   env = var.env


# }

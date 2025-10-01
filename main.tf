terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  features {}
}




locals {
  issuer_uri = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
}

data "azurerm_client_config" "current" {}


resource "azurerm_resource_group" "vnet" {
  name     = var.vnet_resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "kube" {
  name     = var.kube_resource_group_name
  location = var.location
  tags     = local.common_tags
}



#### HUB (BASTION VM VNET) ####
module "hub_network" {
  source                    = "./modules/vnet"
  resource_group_name       = azurerm_resource_group.vnet.name
  location                  = var.location
  vnet_name                 = var.hub_vnet_name
  address_space             = var.hub_address_space
  tags                      = local.common_tags
  kube_address_space_string = var.kube_address_space_string
  vnet_address_space_string = var.hub_address_space_string



  subnets = [
    # {
    #   name             = "AzureFirewallSubnet"
    #   address_prefixes = var.AzureFirewallSubnet
    #   private          = false


    # },
    {
      name : "jumpbox-subnet"
      address_prefixes = var.jumpbox-subnet
      private          = false
    },

    {
      name : "api-gw-subnet"
      address_prefixes = var.api-gw-subnet
      private          = true
    }
    # {
    #   name : "AzureFirewallManagementSubnet"
    #   address_prefixes = var.AzureFirewallManagementSubnet
    #   private          = false
    # }
  ]


}


####  SPOKE (KUBERNETES  VNET)  #####
module "kube_network" {
  source                    = "./modules/vnet"
  resource_group_name       = azurerm_resource_group.kube.name
  location                  = var.location
  vnet_name                 = var.kube_vnet_name
  address_space             = var.kube_address_space
  tags                      = local.common_tags
  kube_address_space_string = var.kube_address_space_string
  vnet_address_space_string = var.hub_address_space_string


  subnets = [
    {
      name             = "aks-subnet"
      address_prefixes = var.aks-subnet
      private          = false
    }
  ]
}


### VNET PEERING FROM BASTION VNET TO KUBERNETES NVET ##
module "vnet_peering" {
  source              = "./modules/vnet_peering"
  vnet_1_name         = var.hub_vnet_name
  vnet_1_id           = module.hub_network.vnet_id
  vnet_1_rg           = azurerm_resource_group.vnet.name
  vnet_2_name         = var.kube_vnet_name
  vnet_2_id           = module.kube_network.vnet_id
  vnet_2_rg           = azurerm_resource_group.kube.name
  peering_name_1_to_2 = "HubToSpoke1"
  peering_name_2_to_1 = "Spoke1ToHub"
  depends_on          = [module.hub_network, module.kube_network]
}




###### NAT #####
module "nat_staging" {
  count               = terraform.workspace == "staging" ? 1 : 0
  source              = "./modules/natgw"
  resource_group_name = azurerm_resource_group.kube.name
  location            = var.location
  name                = "nat-staging"
  sku_name            = "Standard"
  subnet_id           = module.kube_network.subnet_ids["aks-subnet"]
  env                 = var.env
  tags                = local.common_tags
}


###### NAT PROD #####
module "nat_prod" {
  count               = terraform.workspace == "production" ? 1 : 0
  source              = "./modules/natgw"
  resource_group_name = azurerm_resource_group.kube.name
  location            = var.location
  name                = "nat-${var.env}"
  sku_name            = "Standard"
  subnet_id           = module.kube_network.subnet_ids["aks-subnet"]
  env                 = var.env
  tags                = local.common_tags
}



module "k8s_staging_nsg" {
  count               = terraform.workspace == "staging" ? 1 : 0
  source              = "./modules/nsg"
  resource_group_name = azurerm_resource_group.kube.name
  location            = var.location
  env                 = var.env
  tags                = local.common_tags
}


resource "azurerm_network_security_rule" "nsg_staging" {
  count                       = terraform.workspace == "staging" ? 1 : 0
  name                        = "AllowAnyCustom4000Inbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "4000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.kube.name
  network_security_group_name = module.k8s_staging_nsg[0].name
}

# ### ATTACH SECURITY GROUP TO KUBERNETS CLUSTER ####
# resource "azurerm_subnet_network_security_group_association" "aks_nsg_association" {
#   subnet_id                 = module.kube_network.subnet_ids["aks-subnet"]
#   network_security_group_id = terraform.workspace == "staging" ? module.k8s_staging_nsg[0].id  : module.k8s_prod_nsg[0].id 

# }

module "k8s_prod_nsg" {
  count               = terraform.workspace == "production" ? 1 : 0
  source              = "./modules/nsg"
  resource_group_name = azurerm_resource_group.kube.name
  location            = var.location
  env                 = var.env
  tags                = local.common_tags
}

# resource "azurerm_network_security_rule" "nsg_prod" {
#   count               = terraform.workspace == "production" ? 1 : 0
#   name                        = "AllowAnyCustom4000Inbound"
#   priority                    = 110
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "4000"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.kube.name
#   network_security_group_name = module.k8s_prod_nsg[0].name
# }


# ## BASTION NETWORK FIREWALL ##
# module "firewall" {
#   source                        = "./modules/firewall"
#   resource_group                = azurerm_resource_group.vnet.name
#   location                      = var.location
#   pip_name                      = "azureFirewalls-ip"
#   fw_name                       = "kubenetfw"
#   AzureFirewallManagementSubnet = module.hub_network.subnet_ids["AzureFirewallManagementSubnet"]
#   subnet_id                     = module.hub_network.subnet_ids["AzureFirewallSubnet"]
#   firewall_sku_name             = var.firewall_sku_name
#   firewall_sku_tier             = var.firewall_sku_tier
#   tags                          = local.common_tags
# }



# ### KUBERNETES TO FIREWALL HOP##
# module "routetable" {
#   source                 = "./modules/route_table"
#   resource_group         = azurerm_resource_group.vnet.name
#   location               = var.location
#   rt_name                = "kubenetfw_fw_rt"
#   r_name                 = "kubenetfw_fw_r"
#   subnet_id              = module.kube_network.subnet_ids["aks-subnet"]
#   tags                   = local.common_tags
#   hop_type               = "VirtualAppliance"
#   route_name             = "kubenetfw_fw_r"
#   next_hop_in_ip_address = module.firewall.fw_private_ip

# }




# ### KUBERNETES TO FIREWALL HOP##
# module "routetable_nat" {
#   count                  = terraform.workspace == "staging" ? 1 : 0
#   source                 = "./modules/route_table"
#   resource_group         = azurerm_resource_group.kube.name
#   location               = var.location
#   rt_name                = "kubenet_nat_rt"
#   r_name                 = "kubenet_nat_rte"
#   subnet_id              = module.kube_network.subnet_ids["aks-subnet"]
#   tags                   = local.common_tags
#   hop_type               = "VirtualAppliance"
#   route_name             = "kubenet_nat_r"
#   next_hop_in_ip_address = module.nat_staging[0].nat_ip

# }





## NAT ROUTE TABLE  ###
module "nat_routetable" {
  source                 = "./modules/route_table"
  resource_group         = azurerm_resource_group.kube.name
  location               = var.location
  rt_name                = "kubenat_fw_rt"
  r_name                 = "kubenat_fw_r"
  subnet_id              = module.kube_network.subnet_ids["aks-subnet"]
  tags                   = local.common_tags
  hop_type               = "VirtualAppliance"
  route_name             = "kube_nat_rule"
  next_hop_in_ip_address = terraform.workspace == "staging" ? module.nat_staging[0].nat_ip : module.nat_prod[0].nat_ip

}



data "azurerm_kubernetes_service_versions" "current" {
  location       = var.location
  version_prefix = var.kube_version_prefix

}



# Create an Azure Container Registry
resource "azurerm_container_registry" "acr" {
  count               = terraform.workspace == "staging" ? 1 : 0
  name                = "zaho${var.env}repo"
  resource_group_name = azurerm_resource_group.kube.name
  location            = azurerm_resource_group.kube.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.common_tags
}


# resource "azurerm_role_assignment" "kubernetes_pull" {
#   principal_id                     = azurerm_kubernetes_cluster.privateaks.kubelet_identity[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = azurerm_container_registry.acr[0].id
#   skip_service_principal_aad_check = true
# }


# Create an Azure Container Registry Prod
resource "azurerm_container_registry" "acr_prod" {
  count               = terraform.workspace == "production" ? 1 : 0
  name                = "zaho${var.env}repo"
  resource_group_name = azurerm_resource_group.kube.name
  location            = azurerm_resource_group.kube.location
  sku                 = "Premium"
  admin_enabled       = false
  tags                = local.common_tags
}






module "jumpbox" {
  source                  = "./modules/jumpbox"
  location                = var.location
  resource_group          = azurerm_resource_group.vnet.name
  vnet_id                 = module.hub_network.vnet_id
  subnet_id               = module.hub_network.subnet_ids["jumpbox-subnet"]
  dns_zone_name           = join(".", slice(split(".", azurerm_kubernetes_cluster.privateaks.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.privateaks.private_fqdn))))
  dns_zone_resource_group = azurerm_kubernetes_cluster.privateaks.node_resource_group
  kube_config_raw         = local.kube_config_raw
  size                    = var.bastion_vm_size
  storage_account_type    = var.bastion_storage_account_type
  env                     = var.env
  tags                    = local.common_tags
  key_vault_id            = terraform.workspace == "staging" ? azurerm_key_vault.keyvault[0].id : azurerm_key_vault.prod_keyvault[0].id
  tenant_id               = data.azurerm_client_config.current.tenant_id

}






### STAGING SINGLE SERVER DATABASES ##
########### POSTGRESS  SINGLE SERVER STAGING DB #############
module "database_staging" {
  count                         = terraform.workspace == "staging" ? 0 : 0 #### DEPRECATED
  db_sku_type_basic             = true
  source                        = "./modules/postgress"
  resource_group                = azurerm_resource_group.kube.name
  pg_server_name                = var.pg_server_name
  location                      = var.location
  pg_server_sku_name            = "B_Gen5_2"
  pg_server_version             = "11"
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  auto_grow_enabled             = false
  pg_storage_mb                 = 32768
  public_network_access_enabled = true
  ssl_enforcement_enabled       = false
  dbnames                       = local.staging_dbnames
  tags                          = local.common_tags
  subnet_id                     = module.kube_network.subnet_ids["aks-subnet"]
  vnet_address_space_string     = var.hub_address_space_string
  kubevnet_address_space_string = var.kube_address_space_string
  jumpbox_ip_pip                = module.jumpbox.jumpbox_ip
  # firewal_pip                   = module.nat_staging[0].nat_ip

}



########### POSTGRESS STAGING DB #############
module "database__flexible_server" {
  count                         = terraform.workspace == "staging" ? 1 : 0
  db_sku_type_basic             = true
  source                        = "./modules/postgress_flexible_server"
  resource_group                = azurerm_resource_group.kube.name
  pg_server_name                = "${var.pg_server_name}-v2"
  location                      = var.location
  pg_server_sku_name            = "GP_Standard_D2s_v3"
  pg_server_version             = "14"
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  auto_grow_enabled             = false
  pg_storage_mb                 = 32768
  public_network_access_enabled = true
  create_replica                = false
  ssl_enforcement_enabled       = false
  dbnames                       = local.dummy_dbnames
  tags                          = local.common_tags
  subnet_id                     = module.kube_network.subnet_ids["aks-subnet"]
  vnet_address_space_string     = var.hub_address_space_string
  kubevnet_address_space_string = var.kube_address_space_string
  jumpbox_ip_pip                = module.jumpbox.jumpbox_ip
  prevent_destroy               = true
  mode                          = null
  iops                          = 120000 # Performance tier - 120 GiB IOPS
  zone                          = "2"
  storage_tier                  = "P4"
  special                       = false
}


########### POSTGRESS PROD DB #############
module "prod_flexible_server" {
  count                         = terraform.workspace == "production" ? 1 : 0
  db_sku_type_basic             = true
  source                        = "./modules/postgress_flexible_server"
  resource_group                = azurerm_resource_group.kube.name
  pg_server_name                = var.pg_server_name
  location                      = var.location
  pg_server_sku_name            = "GP_Standard_D2s_v3"
  pg_server_version             = "14"
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  auto_grow_enabled             = false
  pg_storage_mb                 = 32768
  public_network_access_enabled = false
  create_replica                = true
  ssl_enforcement_enabled       = false
  dbnames                       = local.prod_dbnames
  tags                          = local.common_tags
  subnet_id                     = module.kube_network.subnet_ids["aks-subnet"]
  vnet_address_space_string     = var.hub_address_space_string
  kubevnet_address_space_string = var.kube_address_space_string
  jumpbox_ip_pip                = module.jumpbox.jumpbox_ip
  prevent_destroy               = true
  mode                          = "SameZone"
  iops                          = 512000 # Performance tier - 512 GiB IOPS
  zone                          = "2"
  storage_tier                  = "P4"
  special                       = false

}

## PROD FIREWALL RULE
resource "azurerm_postgresql_flexible_server_firewall_rule" "prod_allow_all" {
  count            = terraform.workspace == "production" ? 1 : 0
  name             = "allow-all"
  server_id        = module.prod_flexible_server[0].server_id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}




### CACHING REDIS ##

### GENERATE RANDOM PASSWORD ###
resource "random_string" "txt" {
  length    = 4 # Adjust the length as needed
  min_lower = 4 # Ensure at least one lowercase letter
  # min_upper   = null # Ensure at least one uppercase letter
  # min_numeric = 1    # Ensure at least one number
  # special     = null
}


###########   REDIS ############
module "redis_staging" {
  count = 0
  # count                         = terraform.workspace == "staging" ? 1 : 0
  source                        = "./modules/redis"
  resource_group_name           = var.kube_resource_group_name
  public_network_access_enabled = true
  redis_name                    = "${var.env}-insurance-${random_string.txt.result}"
  location                      = var.location
  subnet_id                     = module.kube_network.subnet_ids["aks-subnet"]
  sku_name                      = "Basic"
  family                        = "C"
  redis_version                 = "6"
  capacity                      = "2"
  env                           = var.env
}




########### REDIS ############
module "redis_prod" {
  count = 0
  # count                         = terraform.workspace == "production" ? 1 : 0
  source                        = "./modules/redis"
  resource_group_name           = var.kube_resource_group_name
  public_network_access_enabled = true
  redis_name                    = "${var.env}-zaho-redis-${random_string.txt.result}"
  location                      = var.location
  subnet_id                     = module.kube_network.subnet_ids["aks-subnet"]
  sku_name                      = "Standard"
  family                        = "C"
  redis_version                 = "6"
  env                           = var.env
  capacity                      = "2"
}
# N.B  properties.subnetId requires a Premium sku to be set





# ###### Prod Record Sets ######
# module "prod_record_sets" {
#   count                   = terraform.workspace == "production" ? 1 : 0
#   source                  = "./modules/dns-records"
#   resource_group_name     = var.vnet_resource_group_name
#   target_resource_id      = azurerm_public_ip.example.id
#   zone_name               = var.domain_names[0]
#   zone_zaho_record_names = var.zone_zaho_record_names
#   tags                    = local.common_tags

#   # depends_on = [module.dns_staging_public_zone]
# }


# N.B  properties.subnetId requires a Premium sku to be set.




# ########### METABASE POSTGRESS PROD DB #############
# module "metabase_prod_flexible_server" {
#   count                         = terraform.workspace == "production" ? 1 : 0
#   db_sku_type_basic             = true
#   source                        = "./modules/postgress_flexible_server"
#   resource_group                = azurerm_resource_group.kube.name
#   pg_server_name                = "metabase-prod"
#   location                      = var.location
#   pg_server_sku_name            = "B_Standard_B2s"
#   pg_server_version             = "14"
#   backup_retention_days         = 7
#   geo_redundant_backup_enabled  = false
#   auto_grow_enabled             = false
#   pg_storage_mb                 = 32768
#   public_network_access_enabled = false
#   create_replica                = false
#   ssl_enforcement_enabled       = false
#   dbnames                       = ["metabase"]
#   tags                          = local.common_tags
#   subnet_id                     = module.kube_network.subnet_ids["aks-subnet"]
#   vnet_address_space_string     = var.hub_address_space_string
#   kubevnet_address_space_string = var.kube_address_space_string
#   jumpbox_ip_pip                = module.jumpbox.jumpbox_ip
#   prevent_destroy               = false
#   mode                          = null
#   iops                          = 120000 # Performance tier - 512 GiB IOPS
#   zone                          = "2"
#   storage_tier                  = "P4"
#   special                       = false

# }

# ## PROD FIREWALL RULE
# resource "azurerm_postgresql_flexible_server_firewall_rule" "metabase_prod_allow_all" {
#   count            = terraform.workspace == "production" ? 0 : 0
#   name             = "allow-all"
#   server_id        = module.metabase_prod_flexible_server[0].server_id
#   start_ip_address = "0.0.0.0"
#   end_ip_address   = "255.255.255.255"
# }

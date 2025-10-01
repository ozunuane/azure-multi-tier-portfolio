locals {
  kube_resource_group_name  = azurerm_resource_group.kube.name
  location                  = azurerm_resource_group.kube.location
  kube_config_raw           = azurerm_kubernetes_cluster.privateaks.kube_config_raw
  hub_address_space_string  = var.hub_address_space_string
  kube_address_space_string = var.kube_address_space_string


  # Define multiple tags as a map
  common_tags = {
    Environment = var.env
    Department  = "Zaho-IT"
    Project     = "zaho Insurance"
    ManagedBy   = "Terraform"
  }

}




##################################
#######  DATABASES  ##############
##################################

locals {
  dummy_dbnames = [
    "dummy"
  ]
}


locals {
  staging_dbnames = [
    "insurance_core_mgt",
    "insurance_customer_mgt",
    "insurance_quotation_mgt"
  ]
}

locals {
  prod_dbnames = [
    "zaho_general_core",
    "zaho_shared_customer_mgt",
    "zaho_general_quotation_mgt"

  ]
}

terraform {

  backend "azurerm" {
    resource_group_name  = "zaho-terraform-environment"
    storage_account_name = "zahotfinfrastate"
    container_name       = "terraform-state"
  }
}





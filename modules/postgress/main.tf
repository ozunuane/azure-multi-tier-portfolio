terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
  }
}



locals {
  create_replica    = var.create_replica
  db_sku_type_basic = var.db_sku_type_basic
  source_server_id  = azurerm_postgresql_server.this.id
  server_name       = azurerm_postgresql_server.this.name
}




### GENERATE RANDOM PASSWORD ###
resource "random_password" "adminpassword" {
  keepers = {
    resource_group = var.resource_group
  }
  length      = 10
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
}


resource "azurerm_postgresql_server" "this" {
  name                             = var.pg_server_name
  location                         = var.location
  resource_group_name              = var.resource_group
  administrator_login              = var.administrator_login
  administrator_login_password     = random_password.adminpassword.result
  sku_name                         = var.pg_server_sku_name
  version                          = var.pg_server_version
  storage_mb                       = var.pg_storage_mb
  backup_retention_days            = var.backup_retention_days
  geo_redundant_backup_enabled     = var.geo_redundant_backup_enabled
  auto_grow_enabled                = var.auto_grow_enabled
  public_network_access_enabled    = var.public_network_access_enabled
  ssl_enforcement_enabled          = var.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced = var.ssl_enforcement_enabled == false ? "TLSEnforcementDisabled" : "TLS1_2"
  tags                             = var.tags
  lifecycle {
    ignore_changes = all
  }

}



resource "null_resource" "configure_databases" {
  for_each = toset(var.dbnames)

  provisioner "local-exec" {
    command = <<EOT
    PGPASSWORD=${random_password.adminpassword.result} psql -h ${azurerm_postgresql_server.this.fqdn} -U ${azurerm_postgresql_server.this.administrator_login}@${azurerm_postgresql_server.this.name} -d ${each.value} -c "
      ALTER DATABASE ${each.value} SET search_path = public;
      CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
      CREATE EXTENSION IF NOT EXISTS postgis;
      CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";
      CREATE EXTENSION IF NOT EXISTS pgcrypto;
    "
    EOT
  }

  depends_on = [azurerm_postgresql_database.this]
}




resource "azurerm_postgresql_virtual_network_rule" "example" {
  count                                = local.db_sku_type_basic ? 0 : 1 # Conditionally create based on local.db_sku_type_basic
  name                                 = "postgresql-vnet-rule"
  resource_group_name                  = var.resource_group
  server_name                          = local.server_name
  subnet_id                            = var.subnet_id
  ignore_missing_vnet_service_endpoint = true
}



resource "azurerm_postgresql_server" "replica" {
  count                            = local.create_replica ? 1 : 0 # Conditionally create based on local.create_replica
  create_mode                      = "Replica"
  creation_source_server_id        = local.source_server_id
  name                             = "${var.pg_server_name}-replica"
  location                         = var.location
  resource_group_name              = var.resource_group
  administrator_login              = var.administrator_login
  administrator_login_password     = random_password.adminpassword.result
  sku_name                         = var.pg_server_sku_name
  version                          = var.pg_server_version
  storage_mb                       = var.pg_storage_mb
  backup_retention_days            = var.backup_retention_days
  geo_redundant_backup_enabled     = var.geo_redundant_backup_enabled
  auto_grow_enabled                = var.auto_grow_enabled
  public_network_access_enabled    = var.public_network_access_enabled
  ssl_enforcement_enabled          = var.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced = var.ssl_enforcement_enabled == false ? "TLSEnforcementDisabled" : "TLS1_2"
  lifecycle {
    ignore_changes = all
  }
}




### CREATE DATABASES #####
resource "azurerm_postgresql_database" "this" {
  for_each            = toset(var.dbnames)
  name                = each.value
  resource_group_name = var.resource_group
  server_name         = azurerm_postgresql_server.this.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }

}


locals {
  kubevnet_start_ip = cidrhost(var.kubevnet_address_space_string, 1)
  vnet_start_ip     = cidrhost(var.vnet_address_space_string, 1)
}

resource "azurerm_postgresql_firewall_rule" "firewall_pip" {
  name                = "allow-all"
  resource_group_name = var.resource_group
  server_name         = local.server_name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# ##### Allow all Traffic from Hub and Spoke Network
# resource "azurerm_postgresql_firewall_rule" "kubevnet" {
#   name                = "internal-kubenvet"
#   resource_group_name = var.resource_group
#   server_name         = local.server_name
#   start_ip_address    = local.kubevnet_start_ip
#   end_ip_address      = local.kubevnet_start_ip
# }



# resource "azurerm_postgresql_firewall_rule" "vnet" {
#   name                = "internal-hubvet"
#   resource_group_name = var.resource_group
#   server_name         = local.server_name
#   start_ip_address    = local.vnet_start_ip
#   end_ip_address      = local.vnet_start_ip
# }



# resource "azurerm_postgresql_firewall_rule" "pip" {
#   name                = "public-jumpbox-vpn"
#   resource_group_name = var.resource_group
#   server_name         = local.server_name
#   start_ip_address    = var.jumpbox_ip_pip
#   end_ip_address      = var.jumpbox_ip_pip
# }




# resource "azurerm_postgresql_firewall_rule" "firewall_pip" {
#   name                = "nat-ip"
#   resource_group_name = var.resource_group
#   server_name         = local.server_name
#   start_ip_address    = var.firewal_pip
#   end_ip_address      = var.firewal_pip
# }









# # FLEXIBLE SERVER TO HANDLE azurerm_postgresql_server DEPRECATION  LATER MARCH 2025  ##
# resource "azurerm_postgresql_flexible_server" "this" {
#   name                          = var.pg_server_name
#   resource_group_name           = var.resource_group
#   location                      = var.location
#   version                       = var.pg_server_version
#   administrator_login           = var.administrator_login
#   administrator_password        = random_password.adminpassword.result
#   storage_mb                    = var.pg_storage_mb
#   sku_name                      = var.pg_server_sku_name
#   public_network_access_enabled = var.public_network_access_enabled
#   geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled
#   auto_grow_enabled             = var.auto_grow_enabled
#   backup_retention_days         = var.backup_retention_days
# }

# resource "azurerm_postgresql_flexible_server_database" "this" {
#   for_each  = toset(var.dbnames)
#   name      = each.value
#   server_id = azurerm_postgresql_flexible_server.this.id
#   collation = "en_US.utf8"
#   charset   = "utf8"

#   # prevent the possibility of accidental data loss
#   lifecycle {
#     prevent_destroy = true
#   }
# }






# ############# REPLICA FOR PRODUCTION DB ###################
# ##########################################################
# ### CREATE REPLICA ONLY IF local.create_replica IS TRUE ###
# resource "azurerm_postgresql_flexible_server" "example_replica" {
#   count                         = local.create_replica ? 1 : 0 # Conditionally create based on local.create_replica
#   name                          = "example-replica"
#   resource_group_name           = azurerm_postgresql_flexible_server.this.resource_group_name
#   location                      = var.location
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.this.id
#   version                       = azurerm_postgresql_flexible_server.this.version
#   public_network_access_enabled = true
#   zone                          = "1"
#   storage_mb                    = 32768
#   storage_tier                  = "P30"
#   sku_name                      = "GP_Standard_D2ads_v5"
#   auto_grow_enabled             = true
# }

# resource "azurerm_postgresql_flexible_server_virtual_endpoint" "example" {
#   count             = local.create_replica ? 1 : 0 # Conditionally create based on local.create_replica
#   name              = "${azurerm_postgresql_flexible_server.this.name}-private-endpoint"
#   source_server_id  = azurerm_postgresql_flexible_server.this.id
#   replica_server_id = azurerm_postgresql_flexible_server.example_replica[count.index].id
#   type              = "ReadWrite"
# }





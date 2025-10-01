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
  source_server_id  = azurerm_postgresql_flexible_server.this.id
  server_name       = azurerm_postgresql_flexible_server.this.name
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
  special     = var.special
  lifecycle {
    ignore_changes = all
  }
}


locals {
  kubevnet_start_ip = cidrhost(var.kubevnet_address_space_string, 1)
  vnet_start_ip     = cidrhost(var.vnet_address_space_string, 1)
}


# mode - (Required) The high availability mode for the PostgreSQL Flexible Server. Possible value are SameZone or ZoneRedundant.
# FLEXIBLE SERVER TO HANDLE azurerm_postgresql_server DEPRECATION  LATER MARCH 2025  ##
resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.pg_server_name
  resource_group_name           = var.resource_group
  location                      = var.location
  version                       = var.pg_server_version
  administrator_login           = var.administrator_login
  administrator_password        = random_password.adminpassword.result
  storage_mb                    = var.pg_storage_mb
  sku_name                      = var.pg_server_sku_name
  public_network_access_enabled = var.public_network_access_enabled
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled
  auto_grow_enabled             = var.auto_grow_enabled
  backup_retention_days         = var.backup_retention_days
  zone                          = var.zone


  dynamic "high_availability" {
    for_each = var.mode != null ? [var.mode] : []
    content {
      mode = high_availability.value
    }
  }

  storage_tier = var.storage_tier
  # lifecycle {
  #   ignore_changes = all
  # }

}

resource "azurerm_postgresql_flexible_server_configuration" "require_secure_transport" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "OFF"
}


resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each  = toset(var.dbnames)
  name      = each.value
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "utf8"

  # prevent the possibility of accidental data loss
  # lifecycle {
  #   prevent_destroy = false
  # }
  depends_on = [azurerm_postgresql_flexible_server.this]
}
# Enable PostgreSQL extensions at the server level
resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "pg_stat_statements, postgis, uuid-ossp, pgcrypto, pglogical, postgres_fdw, citext"
}



# Install extensions for all databases
# Install extensions for all databases
resource "null_resource" "install_extensions" {
  depends_on = [
    azurerm_postgresql_flexible_server.this,
    azurerm_postgresql_flexible_server_database.this
  ]
  triggers = {
    extensions_value = azurerm_postgresql_flexible_server_configuration.extensions.value
    db_names         = join(",", tolist(var.dbnames))
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -x  # Enable debugging
      export PGPASSWORD="${random_password.adminpassword.result}"
      DB_HOST="${azurerm_postgresql_flexible_server.this.fqdn}"
      DB_USER="${azurerm_postgresql_flexible_server.this.administrator_login}"
      
      # Fetch list of databases
      DBS=$(psql -h "$DB_HOST" -U "$DB_USER" -d postgres -t -c "SELECT datname FROM pg_database WHERE datname NOT IN ('postgres', 'azure_maintenance', 'azure_sys');")

      for DB in $DBS; do
        echo "Processing database: $DB"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB" -c "ALTER DATABASE \"$DB\" SET search_path = public;"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB" -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB" -c "CREATE EXTENSION IF NOT EXISTS postgis;"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB" -c "CREATE EXTENSION IF NOT EXISTS pglogical;"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB" -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB" -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB" -c "CREATE EXTENSION IF NOT EXISTS postgres_fdw;"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB" -c "CREATE EXTENSION IF NOT EXISTS citext;"
        
        if [ $? -ne 0 ]; then
          echo "Failed to process database: $DB"
        else
          echo "Successfully processed: $DB"
        fi
      done
    EOT
  }


}


############# REPLICA FOR PRODUCTION DB ###################
##########################################################
### CREATE REPLICA ONLY IF local.create_replica IS TRUE ###
resource "azurerm_postgresql_flexible_server" "example_replica" {
  count                         = local.create_replica ? 1 : 0 # Conditionally create based on local.create_replica
  name                          = "${var.pg_server_name}-replica"
  resource_group_name           = azurerm_postgresql_flexible_server.this.resource_group_name
  location                      = var.location
  create_mode                   = "Replica"
  source_server_id              = azurerm_postgresql_flexible_server.this.id
  version                       = azurerm_postgresql_flexible_server.this.version
  public_network_access_enabled = true
  zone                          = azurerm_postgresql_flexible_server.this.zone
  storage_mb                    = var.pg_storage_mb
  storage_tier                  = azurerm_postgresql_flexible_server.this.storage_tier
  sku_name                      = azurerm_postgresql_flexible_server.this.sku_name
  auto_grow_enabled             = true
}

resource "azurerm_postgresql_flexible_server_virtual_endpoint" "example" {
  count             = local.create_replica ? 1 : 0 # Conditionally create based on local.create_replica
  name              = "${azurerm_postgresql_flexible_server.this.name}-private-endpoint"
  source_server_id  = azurerm_postgresql_flexible_server.this.id
  replica_server_id = azurerm_postgresql_flexible_server.example_replica[count.index].id
  type              = "ReadWrite"
}





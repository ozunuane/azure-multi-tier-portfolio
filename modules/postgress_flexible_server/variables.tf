variable "location" {
}

variable "public_network_access_enabled" {
  default = false
}

variable "pg_server_name" {

}
variable "resource_group" {

}



variable "pg_server_sku_name" {
  default = "GP_Gen5_4"

}

variable "pg_storage_mb" {
  default = 640000
}



variable "geo_redundant_backup_enabled" {
  default = false
  type    = bool
}


variable "auto_grow_enabled" {
  default = false
  type    = bool
}


variable "ssl_enforcement_enabled" {
  default = false
}

variable "pg_server_version" {
  default = "11"
}

variable "administrator_login" {
  default = "canalisuser"
}


variable "backup_retention_days" {
  default = 7
}

variable "dbnames" {

}

variable "create_replica" {
  type    = bool
  default = false
}

variable "db_sku_type_basic" {
  type    = bool
  default = false
}

variable "tags" {

}

variable "subnet_id" {

}

variable "vnet_address_space_string" {

}

variable "kubevnet_address_space_string" {

}


variable "jumpbox_ip_pip" {

}


variable "mode" {
  default = null

}

variable "prevent_destroy" {
  type    = bool
  default = true
}
variable "iops" {
  description = "IOPS Performance Tier"
  type        = number
  default     = 512000
}

variable "zone" {

}


variable "storage_tier" {

}
# variable "firewal_pip" {

# }


variable "special" {
  type    = bool
  default = true

}
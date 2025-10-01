variable "resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "The Azure region for the resources"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the Azure Storage Account"
  type        = string
}

variable "account_tier" {
  description = "The storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "The replication type for the storage account"
  type        = string
  default     = "LRS"
}

variable "min_tls_version" {
  description = "The minimum TLS version for the storage account"
  type        = string
  default     = "TLS1_2"
}

variable "containers" {
  description = "A list of storage container names"
  type        = list(string)
  default     = ["container1", "container2"]
}

variable "use_private_access" {
  description = "Set to true for private containers, false for public containers."
  type        = bool
}


variable "env" {
}
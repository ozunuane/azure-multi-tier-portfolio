variable "location" {

}

variable "resource_group_name" {

}

variable "redis_name" {

}

variable "sku_name" {
  default = "Standard"
}

variable "family" {
  default = "C"
}

variable "capacity" {
  default = 2
}

variable "public_network_access_enabled" {
  type = bool
}

variable "env" {

}


variable "redis_version" {

}

variable "subnet_id" {

}
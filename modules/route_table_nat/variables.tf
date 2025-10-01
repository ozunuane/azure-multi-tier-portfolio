variable "resource_group" {
  description = "Resource group where RouteTable will be deployed"
  type        = string
}

variable "location" {
  description = "Location where RouteTable will be deployed"
  type        = string
}

variable "rt_name" {
  description = "RouteTable name"
  type        = string
}

variable "r_name" {
  description = "AKS route name"
  type        = string
}

# variable "firewal_private_ip" {
#   description = "Firewall private IP"
#   type        = string
# }

variable "subnet_id" {
  description = "AKS subnet ID"
  type        = string
}

variable "tags" {

}

variable "hop_type" {

}

variable "route_name" {

}

variable "next_hop_in_ip_address" {
  description = "Firewall private IP"
  type        = string
}


variable "address_prefix" {
  default = "0.0.0.0/0"
}
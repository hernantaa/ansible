variable "number_of_k8s_masters" {}

variable "number_of_k8s_nodes" {}

variable "floatingip_pool" {}

variable "external_net" {}

variable "network_name" {}

variable "router_id" {
  default = ""
}

variable "k8s_nodes" {}

variable "k8s_master_fips" {}

variable "router_internal_port_id" {}

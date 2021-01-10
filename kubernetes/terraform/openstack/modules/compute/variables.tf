variable "cluster_name" {}

variable "az_list" {
  type = list(string)
}

variable "az_list_node" {
  type = list(string)
}

variable "number_of_k8s_masters" {}

variable "number_of_k8s_nodes" {}

variable "master_root_volume_size_in_gb" {}

variable "node_root_volume_size_in_gb" {}

variable "master_volume_type" {}

variable "node_volume_type" {}

variable "public_key_path" {}

variable "image" {}

variable "ssh_user" {}

variable "flavor_k8s_master" {}

variable "flavor_k8s_node" {}

variable "network_name" {}

variable "network_id" {
  default = ""
}

variable "k8s_master_fips" {
  type = list
}

variable "k8s_node_fips" {
  type = list
}

variable "k8s_nodes_fips" {
  type = map
}

variable "master_allowed_remote_ips" {
  type = list
}

variable "k8s_allowed_remote_ips" {
  type = list
}

variable "k8s_allowed_egress_ips" {
  type = list
}

variable "k8s_nodes" {}

variable "wait_for_floatingip" {}

variable "master_allowed_ports" {
  type = list
}

variable "worker_allowed_ports" {
  type = list
}

variable "use_access_ip" {}

variable "use_server_groups" {
  type = bool
}
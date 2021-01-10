module "network" {
  source = "./modules/network"

  external_net       = var.external_net
  network_name       = var.network_name
  subnet_cidr        = var.subnet_cidr
  cluster_name       = var.cluster_name
  dns_nameservers    = var.dns_nameservers
  network_dns_domain = var.network_dns_domain
  use_neutron        = var.use_neutron
  router_id          = var.router_id
}

module "ips" {
  source = "./modules/ips"

  number_of_k8s_masters         = var.number_of_k8s_masters
  number_of_k8s_nodes           = var.number_of_k8s_nodes
  floatingip_pool               = var.floatingip_pool
  external_net                  = var.external_net
  network_name                  = var.network_name
  router_id                     = module.network.router_id
  k8s_nodes                     = var.k8s_nodes
  k8s_master_fips               = var.k8s_master_fips
  router_internal_port_id       = module.network.router_internal_port_id
}

module "compute" {
  source = "./modules/compute"

  cluster_name                                 = var.cluster_name
  az_list                                      = var.az_list
  az_list_node                                 = var.az_list_node
  number_of_k8s_masters                        = var.number_of_k8s_masters
  number_of_k8s_nodes                          = var.number_of_k8s_nodes
  k8s_nodes                                    = var.k8s_nodes
  master_root_volume_size_in_gb                = var.master_root_volume_size_in_gb
  node_root_volume_size_in_gb                  = var.node_root_volume_size_in_gb
  master_volume_type                           = var.master_volume_type
  node_volume_type                             = var.node_volume_type
  public_key_path                              = var.public_key_path
  image                                        = var.image
  ssh_user                                     = var.ssh_user
  flavor_k8s_master                            = var.flavor_k8s_master
  flavor_k8s_node                              = var.flavor_k8s_node
  network_name                                 = var.network_name
  k8s_master_fips                              = module.ips.k8s_master_fips
  k8s_node_fips                                = module.ips.k8s_node_fips
  k8s_nodes_fips                               = module.ips.k8s_nodes_fips

  master_allowed_remote_ips                    = var.master_allowed_remote_ips
  k8s_allowed_remote_ips                       = var.k8s_allowed_remote_ips
  k8s_allowed_egress_ips                       = var.k8s_allowed_egress_ips
  master_allowed_ports                         = var.master_allowed_ports
  worker_allowed_ports                         = var.worker_allowed_ports
  wait_for_floatingip                          = var.wait_for_floatingip
  use_access_ip                                = var.use_access_ip
  use_server_groups                            = var.use_server_groups

  network_id = module.network.router_id
}

output "private_subnet_id" {
  value = module.network.subnet_id
}

output "floating_network_id" {
  value = var.external_net
}

output "router_id" {
  value = module.network.router_id
}

output "k8s_master_fips" {
  value = concat(module.ips.k8s_master_fips)
}

output "k8s_node_fips" {
  value = var.number_of_k8s_nodes > 0 ? module.ips.k8s_node_fips : [for key, value in module.ips.k8s_nodes_fips : value.address]
}
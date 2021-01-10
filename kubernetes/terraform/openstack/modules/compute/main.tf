data "openstack_images_image_v2" "vm_image" {
  name = var.image
}

resource "openstack_compute_keypair_v2" "k8s" {
  name       = "keypair-${var.cluster_name}"
  public_key = chomp(file(var.public_key_path))
}

resource "openstack_compute_servergroup_v2" "k8s_master" {
  count    = "%{if var.use_server_groups}1%{else}0%{endif}"
  name     = "k8s-master-srvgrp"
  policies = ["anti-affinity"]
}

resource "openstack_compute_servergroup_v2" "k8s_node" {
  count    = "%{if var.use_server_groups}1%{else}0%{endif}"
  name     = "k8s-node-srvgrp"
  policies = ["anti-affinity"]
}

resource "openstack_compute_instance_v2" "k8s_master" {
  name              = "${var.cluster_name}-master-${count.index + 1}"
  count             = var.number_of_k8s_masters
  availability_zone = element(var.az_list, count.index)
  image_name        = var.image
  flavor_id         = var.flavor_k8s_master
  key_pair          = openstack_compute_keypair_v2.k8s.name
  security_groups = ["default"]  


  dynamic "block_device" {
    for_each = var.master_root_volume_size_in_gb > 0 ? [var.image] : []
    content {
      uuid                  = data.openstack_images_image_v2.vm_image.id
      source_type           = "image"
      volume_size           = var.master_root_volume_size_in_gb
      volume_type           = var.master_volume_type
      boot_index            = 0
      destination_type      = "volume"
      delete_on_termination = true
    }
  }

  network {
    name = var.network_name
  }

  dynamic "scheduler_hints" {
    for_each = var.use_server_groups ? [openstack_compute_servergroup_v2.k8s_master[0]] : []
    content {
      group = openstack_compute_servergroup_v2.k8s_master[0].id
    }
  }

  metadata = {
    ssh_user         = var.ssh_user
    kube_groups      = "kube-master"
    depends_on       = var.network_id
    use_access_ip    = var.use_access_ip
  }
}

resource "openstack_compute_instance_v2" "k8s_node" {
  name              = "${var.cluster_name}-node-${count.index + 1}"
  count             = var.number_of_k8s_nodes
  availability_zone = element(var.az_list_node, count.index)
  image_name        = var.image
  flavor_id         = var.flavor_k8s_node
  key_pair          = openstack_compute_keypair_v2.k8s.name
  security_groups = ["default"]  

  dynamic "block_device" {
    for_each = var.node_root_volume_size_in_gb > 0 ? [var.image] : []
    content {
      uuid                  = data.openstack_images_image_v2.vm_image.id
      source_type           = "image"
      volume_size           = var.node_root_volume_size_in_gb
      volume_type           = var.node_volume_type      
      boot_index            = 0
      destination_type      = "volume"
      delete_on_termination = true
    }
  }

  network {
    name = var.network_name
  }

  dynamic "scheduler_hints" {
    for_each = var.use_server_groups ? [openstack_compute_servergroup_v2.k8s_node[0]] : []
    content {
      group = openstack_compute_servergroup_v2.k8s_node[0].id
    }
  }

  metadata = {
    ssh_user         = var.ssh_user
    kube_groups      = "kube-node"
    depends_on       = var.network_id
    use_access_ip    = var.use_access_ip
  }
}

resource "openstack_compute_floatingip_associate_v2" "k8s_master" {
  count                 = var.number_of_k8s_masters
  instance_id           = element(openstack_compute_instance_v2.k8s_master.*.id, count.index)
  floating_ip           = var.k8s_master_fips[count.index]
  wait_until_associated = var.wait_for_floatingip
}

resource "openstack_compute_floatingip_associate_v2" "k8s_node" {
  count                 = var.number_of_k8s_nodes
  instance_id           = element(openstack_compute_instance_v2.k8s_node[*].id, count.index)
  floating_ip           = var.k8s_node_fips[count.index]
  wait_until_associated = var.wait_for_floatingip
}
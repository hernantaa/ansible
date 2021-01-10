# Kubernetes cluster name
cluster_name = "example"

# SSH key to use for access to nodes
public_key_path = "~/.ssh/id_rsa.pub"

# image to use for master and worker nodes
image = "<image_name>"

# user on the node (ex. ubuntu on Ubuntu)
ssh_user = "<ssh_user>"

# masters
number_of_k8s_masters = 1

flavor_k8s_master = "<flavor_id>"

master_root_volume_size_in_gb = "<size_in_gb>"

master_volume_type = "<volume_type>"

# worker nodes
number_of_k8s_nodes = 1

flavor_k8s_node = "<flavor_id>"

node_root_volume_size_in_gb = "<size_in_gb>"

node_volume_type = "<volume_type>"

# networking
network_name = "<network_name>"

external_net = "<external_net_id>"

subnet_cidr = "<cidr>"

floatingip_pool = "<floatingip_pool>"

router_id = "<router_id>"

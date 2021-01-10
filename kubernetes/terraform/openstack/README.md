# Provision Kubernetes Nodes on OpenStack with Terraform

Provision a Kubernetes nodes with [Terraform](https://www.terraform.io) on
OpenStack.

### Kubernetes Nodes

You only can create one master node with many kubernetes worker nodes by setting the number of
kubernetes worker nodes. For each nodes will automatically allocating
floating IP addresses.

- Master nodes with etcd
- Kubernetes worker nodes

Note that the Ansible script will report an invalid configuration if you wind up
with an even number of etcd instances since that is not a valid configuration. This
restriction includes standalone etcd nodes that are deployed in a cluster along with
master nodes with etcd replicas. As an example, if you have three master nodes with
etcd replicas and three standalone etcd nodes, the script will fail since there are
now six total etcd replicas.

## Requirements

- [Install Terraform](https://www.terraform.io/intro/getting-started/install.html) 0.12.26 or later
- [Install Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html)
- you already have a suitable OS image in Glance
- you already have a floating IP pool created
- you have security groups enabled
- you have a pair of keys generated that can be used to secure the new hosts

## Module Architecture

The configuration is divided into three modules:

- Network
- IPs
- Compute

## Terraform

Terraform will be used to provision all of the OpenStack resources for kubernetes cluster.

### Configuration

#### OpenStack access and credentials

You need to create openrc file before using terraform.

Below is example openrc and may vary depending on your OpenStack cloud provider,
for an exhaustive list on how to authenticate on OpenStack with Terraform 
please read the [OpenStack provider documentation](https://www.terraform.io/docs/providers/openstack/).

##### Openrc

```ShellSession
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=projectname
export OS_USERNAME=username
export OS_PASSWORD=password
export OS_AUTH_URL=https://openstack:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

#### Cluster variables

The construction of the cluster is driven by values found in
[variables.tf](variables.tf).

For your cluster, edit `inventory/cluster.tfvars`.

|Variable | Description |
|---------|-------------|
|`cluster_name` | All OpenStack resources will use the Terraform variable`cluster_name` (default `example`) in their name to make it easier to track. For example the first compute resource will be named`example-kubernetes-1`. |
|`public_key_path` | Path on your local workstation to the public key file you wish to use in creating the key pairs |
|`image` | Name of the image to use in provisioning the compute resources. Should already be loaded into glance. |
|`ssh_user` | The username to ssh into the image with. This usually depends on the image you have selected |
|`number_of_k8s_masters` | Number of nodes that serve as both master and etcd. These only can be provisioned with floating IP addresses|
|`flavor_k8s_master`,`flavor_k8s_node` | Flavor depends on your openstack installation, you can get available flavor IDs through `openstack flavor list` |
|`master_root_volume_size_in_gb` | Size of the root volume for master, 0 to use ephemeral storage |
|`master_volume_type` | Volume type for master root volume, you can get volume type name through `openstack volume type list` |
|`number_of_k8s_nodes` | Kubernetes worker nodes. These only can be provisioned with floating ip addresses. |
|`node_root_volume_size_in_gb` | Size of the root volume for worker nodes, 0 to use ephemeral storage |
|`node_volume_type` | Volume type for workers root volume, you can get volume type name through `openstack volume type list` |
|`network_name` | The name to be given to the internal network that will be generated |
|`external_net` | UUID of the external network that will be routed to |
|`subnet_cidr` | Subnet CIDR that will be used for the internal network (example `10.10.10.0/24`) |
|`floatingip_pool` | Name of the pool from which floating IPs will be allocated |
|`router_id` | UUID of the router that will be used |

### Initialization

Before Terraform can operate on your cluster you need to install the required
plugins. This is accomplished as follows:

```ShellSession
cd inventory/CLUSTER_NAME
terraform init ../../openstack
```

This should finish fairly quickly telling you Terraform has successfully initialized and loaded necessary modules.

### Provisioning cluster

You can apply the Terraform configuration to your cluster with the following command
issued from your cluster's inventory directory (`inventory/CLUSTER_NAME`):

```ShellSession
terraform apply -var-file=cluster.tfvars ../../openstack
```

### Destroying cluster

You can destroy your new cluster with the following command issued from the cluster's inventory directory:

```ShellSession
terraform destroy -var-file=cluster.tfvars ../../openstack
```

### Terraform output

- `private_subnet_id`: the subnet where your instances are running is used
- `floating_network_id`: the network_id where the floating IP are provisioned is used
- `router_id` : the router_id where internal network attached
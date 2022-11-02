
# Terraform Module for RKE2 with Cilium Mesh

## Terraform Details

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_hetznerdns"></a> [hetznerdns](#provider_hetznerdns) | 2.2.0 |
| <a name="provider_local"></a> [local](#provider_local) | 2.2.3 |
| <a name="provider_rancher2"></a> [rancher2](#provider_rancher2) | 1.24.2 |

#### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cert"></a> [cert](#module_cert) | ./modules/certs | n/a |
| <a name="module_cert_authority"></a> [cert_authority](#module_cert_authority) | ./modules/ca | n/a |
| <a name="module_clusters"></a> [clusters](#module_clusters) | ./modules/cluster | n/a |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name) | Name of the cluster | `string` |
| <a name="input_clusters"></a> [clusters](#input_clusters) | Cluster specification (check terraform.tfvars.example) | `map(object({ cluster_cidr = string, service_cidr = string, cluster_dns = string, cpu = number, memory = number, disk_size = number, ssh_user = string }))` |
| <a name="input_dns_suffix"></a> [dns_suffix](#input_dns_suffix) | DNS Suffix used for communication between the components needed for the certs | `string` |
| <a name="input_hetzner_token"></a> [hetzner_token](#input_hetzner_token) | Token used to set DNS on Hetzner | `string` |
| <a name="input_image_name"></a> [image_name](#input_image_name) | Name of the image to boot the machine with | `string` |
| <a name="input_network_name"></a> [network_name](#input_network_name) | Network used for communication between the nodes | `string` |
| <a name="input_pool_name"></a> [pool_name](#input_pool_name) | Name of the pool | `string` |
| <a name="input_rancher2"></a> [rancher2](#input_rancher2) | User for SSH Login | `map(string)` |
| <a name="input_registry_mirror"></a> [registry_mirror](#input_registry_mirror) | Docker proxy registry (check terraform.tfvars.example) | `list(object({ hostname = string, endpoints = list(string), rewrites = map(string) }))` |
| <a name="input_ssh_keys"></a> [ssh_keys](#input_ssh_keys) | SSH Keys used to connect remotely | `list(string)` |

#### Outputs

No outputs.

## Example

```hcl
rancher2 = {
  url        = ""
  access_key = ""
  secret_key = ""
}

dns_suffix = "mesh.cilium.io"

hetzner_token = ""

#registry_mirror = [{
#  hostname  = "docker.io"
#  endpoints = ["https://harbor.local"]
#  rewrites = {
#    "(.*)" : "docker-proxy/$1"
# }
#}]

network_name = "harvester-public/vlan"
image_name   = "harvester-public/opensuse-leap-15.4"
cluster_name = "cilium"
pool_name    = "pool1"

clusters = {
  "1" = { cluster_cidr = "10.42.0.0/16", service_cidr = "10.43.0.0/16", cluster_dns = "10.43.0.10", cpu = 2, memory = 4, disk_size = 40, ssh_user = "rancher" }
  "2" = { cluster_cidr = "10.44.0.0/16", service_cidr = "10.45.0.0/16", cluster_dns = "10.45.0.10", cpu = 2, memory = 4, disk_size = 40, ssh_user = "rancher" }
  "3" = { cluster_cidr = "10.46.0.0/16", service_cidr = "10.47.0.0/16", cluster_dns = "10.47.0.10", cpu = 2, memory = 4, disk_size = 40, ssh_user = "rancher" }
}

ssh_keys = [
  "ssh-ed25519 AAAA...."
]
```

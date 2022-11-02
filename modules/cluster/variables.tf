variable "cpu" {}
variable "memory" {}
variable "disk_size" {}
variable "ssh_user" {}
variable "id" {}
variable "cluster_cidr" {}
variable "cluster_dns" {}
variable "service_cidr" {}
variable "certs" {}
variable "ca" {}
variable "dns_suffix" {}
variable "cluster_name" {}
variable "pool_name" {}
variable "network_name" {}
variable "image_name" {}
variable "registry_mirror" {
  default = []
}

variable "cpu" {
  default = 2
}
variable "memory" {
  default = "4"
}
variable "disk_size" {
  default = "40"
  
}
variable "ssh_user" {
  default = "rancher"
}
variable "id" {
  default = 1
}
variable "cluster_cidr" {
  default = "10.42.0.0/16"
}
variable "cluster_dns" {
  default = "10.43.0.10"
}
variable "service_cidr" {
  default = "10.43.0.0/16"
}

variable "certs" {
}
variable "ca" {
}
variable "dns_suffix" {
  default = "mesh.cilium.io"
}
variable "cluster_name" {
  default = "cilium"
}
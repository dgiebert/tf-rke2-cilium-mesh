variable "clusters" {
  default = {
    "1" = { cluster_cidr = "10.42.0.0/16", service_cidr = "10.43.0.0/16", cluster_dns = "10.43.0.10" }
    "2" = { cluster_cidr = "10.44.0.0/16", service_cidr = "10.45.0.0/16", cluster_dns = "10.45.0.10" }
    "3" = { cluster_cidr = "10.46.0.0/16", service_cidr = "10.47.0.0/16", cluster_dns = "10.47.0.10" }
  }
}

variable "rancher2" {
  description = "User for SSH Login"
  type        = map(string)
  default = {
    access_key = ""
    secret_key = ""
    url        = ""
  }
  validation {
    condition     = length(var.rancher2.access_key) > 0
    error_message = "Access Key must be provided check https://docs.ranchermanager.rancher.io/reference-guides/user-settings/api-keys"
  }
  validation {
    condition     = length(var.rancher2.secret_key) > 0
    error_message = "Secret Key must be provided check https://docs.ranchermanager.rancher.io/reference-guides/user-settings/api-keys"
  }
  validation {
    condition     = length(var.rancher2.url) > 0
    error_message = "Rancher URL must be provided"
  }
}

variable "dns_suffix" {
  default = "mesh.cilium.io"
}
variable "cluster_name" {
  default = "cilium"
}
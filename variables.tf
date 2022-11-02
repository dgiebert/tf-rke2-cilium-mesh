variable "clusters" {
  type    = map(map(string))
  default = {}
  validation {
    condition     = length(var.clusters) > 1
    error_message = "Please check the terraform.tfvars.example"
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
  description = "DNS Suffix used for communication between the components needed for the certs"
  default     = ""
  validation {
    condition     = length(var.dns_suffix) > 0
    error_message = "Please provide a valid DNS suffix for the cluster (e.g mesh.cilium.io)"
  }
}

variable "cluster_name" {
  description = "Name of the cluster"
  default     = ""
  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "Please provide a name for the clusters (e.g. cilium)"
  }
}

variable "pool_name" {
  description = "Name of the pool"
  default     = ""
  validation {
    condition     = length(var.pool_name) > 0
    error_message = "Please provide a name for the master pool (e.g. cplane)"
  }
}

variable "network_name" {
  description = "Network used for communication between the nodes"
  default     = ""
  validation {
    condition     = length(var.network_name) > 0
    error_message = "Please provide the name of the network to use (e.g. harvester-public/vlan)"
  }
}

variable "image_name" {
  description = "Name of the image to boot the machine with"
  default     = ""
  validation {
    condition     = length(var.image_name) > 0
    error_message = "Please provide the name of the image to use (e.g. harvester-public/opensuse-leap-15.4)"
  }
}

variable "ssh_keys" {
  description = "SSH Keys used to connect remotely"
  type        = list(string)
  default     = []
}

variable "hetzner_token" {
  default = ""
}

variable "registry_mirror" {
  default = []
}
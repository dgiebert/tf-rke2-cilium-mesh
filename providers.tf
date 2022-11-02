terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.24.2"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.3"
    }
    hetznerdns = {
      source = "timohirt/hetznerdns"
      version = "2.2.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.2.3"
    }
  }
  required_version = "~> 1.3"
}

provider "rancher2" {
  api_url    = var.rancher2.url
  access_key = var.rancher2.access_key
  secret_key = var.rancher2.secret_key
}

provider "hetznerdns" {
  apitoken = var.hetzner_token
}
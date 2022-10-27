module "cert_authority" {
  source = "./modules/ca"
}

module "cert" {
  source   = "./modules/certs"
  for_each = var.clusters
  ca       = module.cert_authority.ca
  dns_name = "${var.cluster_name}-${each.key}.${var.dns_suffix}"
}

module "clusters" {
  for_each     = var.clusters
  source       = "./modules/cluster"
  id           = each.key
  cluster_cidr = each.value.cluster_cidr
  service_cidr = each.value.service_cidr
  cluster_dns  = each.value.cluster_dns
  certs        = module.cert
  ca           = module.cert_authority.ca
  cluster_name = var.cluster_name
  dns_suffix   = var.dns_suffix
}

resource "local_file" "kubeconfig" {
  for_each = module.clusters
  content  = each.value.cluster.kube_config
  filename = "${path.module}/kubeconfigs/${var.cluster_name}-${each.key}"
}

module "cert_authority" {
  source = "./modules/ca"
}

module "cert" {
  source     = "./modules/certs"
  for_each   = var.clusters
  ca         = module.cert_authority.ca
  dns_suffix = var.dns_suffix
}

module "clusters" {
  for_each     = var.clusters
  source       = "./modules/cluster"
  id           = each.key
  cluster_name = var.cluster_name
  # Node Settings
  cpu       = coalesce(each.value.cpu, 2)              # Default: 2 Cores
  memory    = coalesce(each.value.memory, 4)           # Default: 4Gi RAM
  disk_size = coalesce(each.value.disk_size, 40)       # Default: 40Gi disk
  ssh_user  = coalesce(each.value.ssh_user, "rancher") # Default: rancher
  # Individual Cluster Settings
  cluster_cidr = each.value.cluster_cidr
  service_cidr = each.value.service_cidr
  cluster_dns  = each.value.cluster_dns
  # Global Cluster Settings
  pool_name       = var.pool_name
  network_name    = var.network_name
  image_name      = var.image_name
  registry_mirror = var.registry_mirror
  # Cilium Settings
  certs      = module.cert
  ca         = module.cert_authority.ca
  dns_suffix = var.dns_suffix
}

resource "local_file" "kubeconfig" {
  for_each = module.clusters
  content  = each.value.cluster.kube_config
  filename = "${path.module}/kubeconfigs/${var.cluster_name}-${each.key}"
}

resource "rancher2_cluster_sync" "harvester" {
  for_each      = module.clusters
  cluster_id    = each.value.cluster.cluster_v1_id
  node_pool_ids = ["${each.value.cluster.name}-${each.value.cluster.rke_config[0].machine_pools[0].name}"]
}

# Optional DNS entries using Hetzner DNS
data "hetznerdns_zone" "z1" {
  count = var.hetzner_token != "" ? 1 : 0
  name  = "giebert.dev"
}

resource "hetznerdns_record" "www" {
  for_each = var.hetzner_token != "" ? rancher2_cluster_sync.harvester : {}
  zone_id  = data.hetznerdns_zone.z1[0].id
  name     = "${var.cluster_name}-${each.key}.cilium"
  value    = each.value.nodes[0].ip_address
  type     = "A"
  ttl      = 60
}

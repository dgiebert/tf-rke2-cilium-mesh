data "rancher2_cloud_credential" "harvester" {
  name = "harvester"
}
# Create a new rancher2 machine config v2 using harvester node_driver
resource "rancher2_machine_config_v2" "harvester" {
  generate_name = "${var.cluster_name}-${var.id}"
  harvester_config {
    vm_namespace = "default"
    cpu_count    = var.cpu
    memory_size  = var.memory
    disk_size    = var.disk_size
    network_name = var.network_name
    image_name   = var.image_name
    ssh_user     = var.ssh_user
    user_data    = <<EOF
#cloud-config
user: rancher
ssh_authorized_keys:
%{for key in var.ssh_keys ~}
  - ${key}
%{endfor ~}
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - nano
  - htop
  - open-iscsi 
  - nfs-client
  - ipvsadm
runcmd:
  - systemctl enable --now qemu-guest-agent
  - sed -i "s/GRUB_TIMEOUT=10/GRUB_TIMEOUT=1/g" /etc/default/grub
  - grub2-mkconfig > /boot/grub2/grub.cfg
write_files:
  - path: /etc/sysctl.d/90-kubelet.conf
    content: |
      vm.panic_on_oom=0
      vm.overcommit_memory=1
      kernel.panic=10
      kernel.panic_on_oops=1
      kernel.keys.root_maxbytes=25000000
  - path: /etc/sysctl.d/90-rke2-forwarding.conf
    content: |
      net.ipv4.conf.all.forwarding=1
      net.ipv6.conf.all.forwarding=1
  - path: /root/.bashrc
    content: |
      # Use RKE Binaries
      PATH=/var/lib/rancher/rke2/bin:$PATH
      
      # Export the correct configs for the cli tools
      export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
      export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
      
      # Autocompletion
      source <(kubectl completion bash)
      alias k=kubectl
      complete -o default -F __start_kubectl k
EOF
  }
}

resource "rancher2_cluster_v2" "harvester" {
  name               = "${var.cluster_name}-${var.id}"
  kubernetes_version = "v1.24.4+rke2r1"
  rke_config {
    machine_pools {
      name                         = var.pool_name
      cloud_credential_secret_name = data.rancher2_cloud_credential.harvester.id
      control_plane_role           = true
      etcd_role                    = true
      worker_role                  = true
      quantity                     = 1
      machine_config {
        kind = rancher2_machine_config_v2.harvester.kind
        name = rancher2_machine_config_v2.harvester.name
      }
    }
    machine_selector_config {
      config = {
        cloud-provider-name = ""
      }
    }
    registries {
      dynamic "mirrors" {
        for_each = var.registry_mirror
        content {
          hostname  = mirrors.value["hostname"]
          endpoints = mirrors.value["endpoints"]
          rewrites  = mirrors.value["rewrites"]
        }
      }
    }
    machine_global_config = <<EOF
cluster-cidr: ${var.cluster_cidr}
cluster-dns: ${var.cluster_dns}
service-cidr: ${var.service_cidr}
cni: "cilium"
disable-kube-proxy: true
EOF
    chart_values          = <<-EOF
rke2-cilium:
  kubeProxyReplacement: strict
  k8sServiceHost: 127.0.0.1
  k8sServicePort: 6443
  # Transparent Encryption
  l7Proxy: false
  encryption:
    enabled: true
    type: wireguard
  # Cluster-mesh
  cluster:
    name: ${var.cluster_name}-${var.id}
    id: ${var.id}
  operator:
    replicas: 1
    rollOutPods: true
  hubble:
    enabled: true
    relay:
      enabled: true
    ui:
      enabled: true
    tls:
      auto:
        method: cronJob
  # Roll out cilium agent pods automatically
  rollOutCiliumPods: true
  tls:
    ca:
      cert: ${base64encode(var.ca.cert_pem)}
      key: ${base64encode(var.ca.private_key_pem)}
  ipv4NativeRoutingCIDR: "10.0.0.0/9"
  clustermesh:
    useAPIServer: true
    config:
      enabled: true
      clusters:
      %{for key, client in { for k, v in var.certs : k => v if !(k == var.id) } ~}
      - name: ${var.cluster_name}-${key}
        address: ${var.cluster_name}-${key}.${var.dns_suffix}
        port: 32379
        tls:
          cert: ${base64encode(client.certs["remote"].cert)}
          key: ${base64encode(client.certs["remote"].key)}
      %{endfor ~}
    apiserver:
      tls:
        auto:
          enabled: false
        admin:
          cert: ${base64encode(var.certs[var.id].certs["root"].cert)}
          key: ${base64encode(var.certs[var.id].certs["root"].key)}
        remote:
          cert: ${base64encode(var.certs[var.id].certs["externalworkload"].cert)}
          key: ${base64encode(var.certs[var.id].certs["externalworkload"].key)}
        server:
          cert: ${base64encode(var.certs[var.id].certs["ClusterMesh Server"].cert)}
          key: ${base64encode(var.certs[var.id].certs["ClusterMesh Server"].key)}
        client:
          cert: ${base64encode(var.certs[var.id].certs["remote"].cert)}
          key: ${base64encode(var.certs[var.id].certs["remote"].key)}
        ca:
          cert: ${base64encode(var.ca.cert_pem)}
          key: ${base64encode(var.ca.private_key_pem)}
EOF
  }
}

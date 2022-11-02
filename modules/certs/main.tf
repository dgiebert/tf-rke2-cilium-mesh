resource "tls_private_key" "cert" {
  for_each    = toset(["externalworkload", "root", "remote", "ClusterMesh Server"])
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "cert" {
  for_each        = toset(["externalworkload", "root", "remote", "ClusterMesh Server"])
  private_key_pem = tls_private_key.cert[each.key].private_key_pem

  subject {
    common_name = each.value
  }
  dns_names = ["*.${var.dns_suffix}", "*.mesh.cilium.io", "localhost"]
  ip_addresses = ["127.0.0.1"]
}

resource "tls_locally_signed_cert" "cert" {
  for_each         = tls_cert_request.cert
  cert_request_pem = each.value.cert_request_pem

  ca_private_key_pem = var.ca.private_key_pem
  ca_cert_pem        = var.ca.cert_pem

  validity_period_hours = "8760"
  allowed_uses          = ["key_encipherment", "digital_signature", "client_auth", "server_auth"]
  set_subject_key_id    = true
}

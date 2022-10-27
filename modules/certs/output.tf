output "certs" {
  value = { 
    for key, value in tls_locally_signed_cert.cert : key => {
        cert = value.cert_pem
        key = tls_private_key.cert[key].private_key_pem
    }
  }
}
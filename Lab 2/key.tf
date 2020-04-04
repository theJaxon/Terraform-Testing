/*
    Create a key on the fly
    https://www.terraform.io/docs/providers/tls/r/private_key.html
*/

resource "tls_private_key" "tf_generated_key" {
  algorithm   = "RSA"
  ecdsa_curve = "2048"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "generated_aws_key"
  public_key = "${tls_private_key.tf_generated_key.public_key_openssh}"
}

/*
    Secrets metadata
*/
resource "aws_secretsmanager_secret" "tf_key_secretmanager_metadata2" {
  name = "tf_key_secretmanager_metadata2"
}

/*
    Store the private keys in AWS secrets
*/
resource "aws_secretsmanager_secret_version" "store_aws_secret" {
  secret_id     = "${aws_secretsmanager_secret.tf_key_secretmanager_metadata2.id}"
  secret_string = "${tls_private_key.tf_generated_key.private_key_pem}"
}

/*
    Store the private keys offline locally
*/
resource "local_file" "aws_secret_local_file" {
    content     = "public key\n ${tls_private_key.tf_generated_key.public_key_pem} \nPrivate key\n ${tls_private_key.tf_generated_key.private_key_pem}"
    filename = "${path.module}/aws_secret.txt"
}

output "public_key" {
  value = "${tls_private_key.tf_generated_key.public_key_pem}"
  description = "The TLS genreated public key value"
}

output "private_key" {
  value = "${tls_private_key.tf_generated_key.private_key_pem}"
  description = "The TLS genreated private key value"
}


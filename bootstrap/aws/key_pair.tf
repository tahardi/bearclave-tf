resource "aws_key_pair" "ci" {
  key_name   = "bearclave-ci"
  public_key = var.ci_ssh_public_key
}

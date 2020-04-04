terraform {
  backend "s3" {
    bucket = "theterraformstate"
    key    = "terraform/state_backup/terraform.tfstate"
    region = "us-west-2"
  }
}

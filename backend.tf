terraform {
  backend "s3" {
    bucket = "dev-terraform-state-us-west-2"
    key    = "testing/terraform.tfstate"
    region = "us-west-2"
  }
}

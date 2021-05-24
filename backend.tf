terraform {
  backend "s3" {
    bucket = var.s3bucket
    key    = var.s3bucketkey
    region = var.region
  }
}

provider "aws" {
  region = var.region
}

locals {
  bucket_name = "rke2-loki-logging-bucket"
}
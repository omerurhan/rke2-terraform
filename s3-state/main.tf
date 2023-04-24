module "s3_bucket" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v3.8.2"

  bucket = "rke2-infrastructure-state"
  #acl    = "private"

  versioning = {
    enabled = true
  }

}

variable "region" {
    type = string
}
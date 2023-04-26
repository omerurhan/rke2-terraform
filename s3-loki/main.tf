module "s3_bucket" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v3.8.2"

  bucket = local.bucket_name
  
  #acl    = "private"

  versioning = {
    enabled = false
  }
}
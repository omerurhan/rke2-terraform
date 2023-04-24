module "dynamodb_table" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table.git?ref=v3.2.0"

  name     = "terraform-lock-table"
  hash_key = "LockID"

  attributes = [ 
    {
    name = "LockID"
    type = "S"
    }
  ]

}

variable "region" {
    type = string
}
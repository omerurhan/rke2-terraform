variable "region" {
  type = string
}

variable "client_cidr" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "ami" {
  type = string
}

variable "tags" {
  type = object({
    owner = string
    environment = string
  })
}

variable "cp_count" {
  type = number
  default = 3
}

variable "worker_count" {
  type = number
  default = 3
}

variable "environment" {
  type = string
}

variable "instance_role" {
  type = string
}
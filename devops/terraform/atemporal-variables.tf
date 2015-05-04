variable "key_name" {
  default = "atemporal"
}

variable "region" {
  default = "us-west-1"
}

variable "public_key" {
  description = "atemporal deployer-key"
}

variable "access_key" {
  description = "AWS access key"
}

variable "secret_key" {
  description = "AWS secret key"
}

variable "server_instances_count" {
  default = "3"
}

variable "coreos_ami" {
  default = "ami-4df91b09"
}

variable "docker_username" {}
variable "cluster_discovery" {}

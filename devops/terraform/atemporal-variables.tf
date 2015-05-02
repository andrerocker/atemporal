variable "key_name" {
  default = "atemporal"
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

variable "docker_username" {}
variable "cluster_discovery" {}

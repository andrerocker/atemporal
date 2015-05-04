provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_key_pair" "atemporal" {
  key_name = "${var.key_name}" 
  public_key = "${var.public_key}"
}

resource "aws_security_group" "atemporal" {
  name = "atemporal"
  description = "atemporal security group"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    self = true
  }
}

resource "aws_security_group" "atemporal-worker" {
  name = "atemporal-worker"
  description = "atemporal worker security group"
 
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

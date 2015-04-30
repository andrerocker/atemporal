provider "aws" {
  region = "us-west-1"
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
    from_port = 4001
    to_port = 4001
    protocol = "tcp"
    self = true
  }

  ingress {
    from_port = 7001
    to_port = 7001
    protocol = "tcp"
    self = true
  }
}

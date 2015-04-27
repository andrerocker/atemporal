provider "aws" {
  region = "us-east-1"
  access_key = "--"
  secret_key = "--"
}

resource "aws_key_pair" "atemporal" {
  key_name = "${var.key_name}" 
  public_key = "${var.public_key}"
}

resource "aws_security_group" "atemporal" {
  name = "atemporal"
  description = "atemporal security group"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_instance" "web" {
  ami = "ami-d85e75b0"
  instance_type = "t1.micro"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.atemporal.name}"]

  connection {
    user = "ubuntu"
    agent = true
  }

  provisioner "remote-exec" {
    script = "install-package.sh"
  }
}
 
resource "aws_elb" "atemporal" {
  name = "atemporal"
  availability_zones = ["${aws_instance.web.availability_zone}"]

  listener {
    instance_port = 80
    instance_protocol = "http"

    lb_port = 80
    lb_protocol = "http"
  }

  instances = ["${aws_instance.web.id}"]
}

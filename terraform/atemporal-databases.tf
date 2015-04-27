resource "aws_db_security_group" "default" {
    name = "atemporal_sg"
    description = "RDS default security group"

    ingress {
        cidr = "0.0.0.0/0"
    }
}

resource "aws_db_instance" "database" {
    identifier = "atemporal-rds"
    allocated_storage = 5
    engine = "postgres"
    engine_version = "9.4.1"
    instance_class = "db.t1.micro"
    name = "atemporalpg"
    username = "atemporal"
    password = "atemporal"
    multi_az = false
    security_group_names = ["${aws_db_security_group.default.name}"]
}

resource "aws_instance" "redis" {
  ami = "ami-d85e75b0"
  instance_type = "t1.micro"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.atemporal.name}"]

  connection {
    user = "ubuntu"
    agent = true
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get update && sudo apt-get install -y --force-yes redis-server"]
  }
}


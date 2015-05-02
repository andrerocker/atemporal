resource "aws_db_security_group" "default" {
    name = "atemporal_db"
    description = "RDS default security group"

    ingress {
      cidr = "0.0.0.0/0"
    }
}

resource "aws_db_instance" "database" {
    identifier = "atemporal-rds"
    allocated_storage = 10
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
  depends_on = ["aws_key_pair.atemporal"]
  ami = "ami-d16a8b95"
  instance_type = "t1.micro"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.atemporal.name}"]

  tags {
    Name = "Atemporal Redis"
  }

  connection {
    user = "ubuntu"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y --force-yes redis-server",
      "sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf",
      "sudo service redis-server restart && sleep 1"
    ]
  }
}


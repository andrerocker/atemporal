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

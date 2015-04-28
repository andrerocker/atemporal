resource "aws_instance" "web" {
  # ubuntu 14.04 pv
  ami = "ami-d85e75b0"
  instance_type = "t1.micro"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.atemporal.name}"]
}
 
resource "aws_elb" "loadbalancer" {
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

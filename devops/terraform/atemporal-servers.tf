resource "aws_elb" "loadbalancer" {
  depends_on = ["aws_instance.servers"]
  name = "atemporal"
  availability_zones = ["${aws_instance.servers.*.availability_zone}"]

  listener {
    instance_port = 80
    instance_protocol = "http"

    lb_port = 80
    lb_protocol = "http"
  }

  instances = ["${aws_instance.servers.*.id}"]
}

resource "aws_instance" "servers" {
  depends_on = ["aws_security_group.atemporal"]
  instance_type = "t1.micro"
  ami = "ami-4df91b09"
  count = "${var.server_instances_count}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.atemporal.name}"]

  tags {
        Name = "Atemporal CoreOS ${count.index}"
  }
  
  user_data = "${replace(replace(file("../coreos/cloud-config.yml"), "DISCOVERY", var.cluster_discovery), "DOCKER_USERNAME", var.docker_username)}"
}

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
  count = "3"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.atemporal.name}"]

  tags {
        Name = "Atemporal CoreOS ${count.index}"
  }

  user_data = <<EOF
#cloud-config

coreos:
  etcd:
    discovery: ${var.cluster_discovery}
    addr: $private_ipv4:4001
    peer-addr: $private_ipv4:7001
  units:
    - name: etcd.service
      command: start
    - name: fleet.service
      command: start
    - name: httpsrv.service
      command: start
      content: |
        [Unit]
        Description=Atemporal http
        After=docker.service
        Requires=docker.service
        
        [Service]
        TimeoutStartSec=900s
        ExecStartPre=-/usr/bin/docker kill httpsrv
        ExecStartPre=-/usr/bin/docker rm httpsrv
        ExecStartPre=/usr/bin/docker pull andrerocker/httpsrv
        ExecStart=/usr/bin/docker run --name httpsrv -p 80:80 andrerocker/httpsrv
        ExecStop=/usr/bin/docker stop httpsrv
EOF  
}

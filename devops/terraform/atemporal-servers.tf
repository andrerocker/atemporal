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

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 2
    target = "HTTP:80/"
    interval = 5
  }

  instances = ["${aws_instance.servers.*.id}"]
}

resource "aws_instance" "servers" {
  depends_on = ["aws_security_group.atemporal", "aws_instance.redis"]
  instance_type = "c1.medium"
  ami = "ami-4df91b09"
  count = "${var.server_instances_count}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.atemporal.name}"]

  tags {
        Name = "Atemporal CoreOS ${count.index}"
  }

  user_data = <<EOF
#cloud-config

write_files:
  - path: /etc/atemporal
    content: |
      RAILS_ENV=production
      REDIS_URL=redis://${aws_instance.redis.private_ip}:6379
      DATABASE_URL=postgres://atemporal:atemporal@${aws_db_instance.database.endpoint}/atemporalpg
      SECRET_KEY_BASE=c39362cda691f8394182f72c0c5b02bb6da54a9be6e374e948a7672db636de4e284a2e0f6dbe16b92f885d95e8075b2cfbcadc31dd2b4dd3e94eaac8711e1b3e

coreos:
  units:
    - name: atemporal.service
      command: start
      content: |
        [Unit]
        Description=Atemporal
        After=docker.service
        Requires=docker.service
        
        [Service]
        TimeoutStartSec=10m
        ExecStartPre=-/usr/bin/docker kill atemporal
        ExecStartPre=-/usr/bin/docker rm atemporal
        ExecStartPre=/usr/bin/docker pull ${var.docker_username}/atemporal
        ExecStart=/usr/bin/docker run --env-file=/etc/atemporal --name atemporal -p 80:8080 ${var.docker_username}/atemporal /start
        ExecStop=/usr/bin/docker stop atemporal
EOF
}

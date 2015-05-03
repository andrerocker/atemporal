output "loadbalancer" {
  value = "${aws_elb.loadbalancer.dns_name}"
}

output "database" {
  value = "${aws_db_instance.database.address}"
}

output "server" {
  value = "${join(", ", aws_instance.servers.*.public_dns)}"
}

output "loadbalancer" {
  value = "${aws_elb.loadbalancer.dns_name}"
}

output "database" {
  value = "${aws_db_instance.database.address}"
}

output "redis" {
  value = "${aws_instance.redis.public_dns}"
}

output "server" {
  value = "${join(", ", aws_instance.servers.*.public_dns)}"
}

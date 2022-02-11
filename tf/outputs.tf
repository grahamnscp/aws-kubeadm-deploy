# Output Values:

output "region" {
  value = "${var.aws_region}"
}

output "route53_subdomain" {
  value = "${var.name_prefix}"
}
output "route53_domain" {
  value = "${var.route53_domainname}"
}

output "infra-public-name" {
  value = "${aws_instance.infra.public_dns}"
}
output "infra-public-ip" {
  value = "${aws_instance.infra.public_ip}"
}
output "infra-private-ip" {
  value = "${aws_instance.infra.private_ip}"
}

output "master-primary-public-name" {
  value = "${element(aws_instance.master.*.public_dns,0)}"
}
output "master-primary-public-ip" {
  value = "${element(aws_instance.master.*.public_ip,0)}"
}
output "master-primary-private-ip" {
  value = "${element(aws_instance.master.*.private_ip,0)}"
}

output "master-public-names" {
  value = ["${aws_instance.master.*.public_dns}"]
}
output "master-public-ips" {
  value = ["${aws_instance.master.*.public_ip}"]
}
output "master-private-ips" {
  value = ["${aws_instance.master.*.private_ip}"]
}
output "node-public-names" {
  value = ["${aws_instance.node.*.public_dns}"]
}
output "node-public-ips" {
  value = ["${aws_instance.node.*.public_ip}"]
}
output "node-private-ips" {
  value = ["${aws_instance.node.*.private_ip}"]
}

output "route53-admin" {
  value = "${aws_route53_record.admin.name}"
}
output "route53-apps" {
  value = "${aws_route53_record.apps.name}"
}
output "route53-infra" {
  value = ["${aws_route53_record.infra.name}"]
}
output "route53-masters" {
  value = ["${aws_route53_record.master.*.name}"]
}
output "route53-nodes" {
  value = ["${aws_route53_record.node.*.name}"]
}

output "elb-admin-public-dns" {
  value = ["${aws_elb.admin.dns_name}"]
}
output "elb-admin-instances" {
  value = ["${aws_elb.admin.*.instances}"]
}
output "elb-apps-instances" {
  value = ["${aws_elb.apps.*.instances}"]
}

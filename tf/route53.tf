# Route53 DNS Entries:

#resource "aws_route53_zone" "labs" {
#  name = "${var.domainname}"
#  comment = "${var.name_prefix} Shared Labs domain zone"
#}

#resource "aws_route53_record" "labs-ns" {
#    zone_id = "${aws_route53_zone.labs.zone_id}"
#    name = "${var.domainname}"
#    type = "NS"
#    ttl = "30"
#    records = [
#        "${aws_route53_zone.labs.name_servers.0}",
#        "${aws_route53_zone.labs.name_servers.1}",
#        "${aws_route53_zone.labs.name_servers.2}",
#        "${aws_route53_zone.labs.name_servers.3}"
#    ]
#}

resource "aws_route53_record" "admin" {
#  zone_id = "${aws_route53_zone.labs.zone_id}"
  zone_id = "${var.route53_zone_id}"
  name = "${var.admin_dns}.${var.domainname}."
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.admin.dns_name}"]
}

resource "aws_route53_record" "apps" {
#  zone_id = "${aws_route53_zone.labs.zone_id}"
  zone_id = "${var.route53_zone_id}"
  name = "*.${var.apps_dns}.${var.domainname}."
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.apps.dns_name}"]
}

resource "aws_route53_record" "bootstrap" {
#  zone_id = "${aws_route53_zone.labs.zone_id}"
  zone_id = "${var.route53_zone_id}"
  name = "bootstrap.${var.domainname}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.bootstrap.public_ip}"]
}

resource "aws_route53_record" "master" {
  count = "${var.master_count}"
#  zone_id = "${aws_route53_zone.labs.zone_id}"
  zone_id = "${var.route53_zone_id}"
  name = "master${count.index + 1}.${var.domainname}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.master.*.public_ip, count.index)}"]
}

resource "aws_route53_record" "node" {
  count = "${var.node_count}"
#  zone_id = "${aws_route53_zone.labs.zone_id}"
  zone_id = "${var.route53_zone_id}"
  name = "${var.node_dns}${count.index + 1}.${var.domainname}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.node.*.public_ip, count.index)}"]
}


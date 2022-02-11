# Security Groups:

resource "aws_security_group" "instance-sg" {
  name = "${var.name_prefix}_instance-default"
  description = "Default Security Group for Instance Nodes"

  vpc_id = "${aws_vpc.nw-vpc.id}"

#  ingress {
#    from_port = 22
#    to_port = 22
#    protocol = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
  # allow all ping
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # allow self
  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    self = true
  }
  # allow all for internal subnet
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["${aws_subnet.nw-subnet.cidr_block}"]
  }
  # open all for specific ips
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.ip_cidr_me}"]
  }
  # open to all
  #ingress {
  #  from_port = 0
  #  to_port = 0
  #  protocol = -1
  #  cidr_blocks = ["0.0.0.0/0"]
  #}
  # egress out for all
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


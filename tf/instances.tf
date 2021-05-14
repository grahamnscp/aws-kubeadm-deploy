# Instances:

# Bootstrap Instance:
#
resource "aws_instance" "bootstrap" {
  instance_type = "${var.bootstrap_instance_type}"
  ami           = "${var.aws_centos_ami}"
  key_name      = "${var.key_name}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
    delete_on_termination = true
  }

  # Second disk for docker storage
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "${var.docker_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

#  count = "1"

  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  subnet_id              = "${aws_subnet.nw-subnet.id}"

  user_data              = "${file("userdata.sh")}"

  tags = {
    Name = "${var.name_prefix}_bootstrap"
    owner = "${var.owner_tag}"
    expiration = "${var.expiration_tag}"
    purpose = "${var.purpose_tag}"
  }
}

# Manager Instances:
#
resource "aws_instance" "master" {
  instance_type = "${var.master_instance_type}"
  ami           = "${var.aws_centos_ami}"
  key_name      = "${var.key_name}"

  iam_instance_profile = "${aws_iam_instance_profile.master_instance_profile.id}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
    delete_on_termination = true
  }

  # Second disk for containerd storage
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "${var.docker_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  count = "${var.master_count}"

#  security_groups = [ "${aws_security_group.instance.id}" ]
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  subnet_id              = "${aws_subnet.nw-subnet.id}"

  user_data              = "${file("userdata.sh")}"

#  availability_zone = "${element(split(",", var.availability_zones), count.index) }"
#  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "${var.name_prefix}_master${count.index + 1}"
    owner = "${var.owner_tag}"
    expiration = "${var.expiration_tag}"
    purpose = "${var.purpose_tag}"
    KubernetesCluster = "${var.name_prefix}.k8s.local"
  }
}


# Node Instances:
#
resource "aws_instance" "node" {
  ami           = "${var.aws_centos_ami}"
  instance_type = "${var.node_instance_type}"
  key_name      = "${var.key_name}"

  iam_instance_profile = "${aws_iam_instance_profile.node_instance_profile.id}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
    delete_on_termination = true
  }

  # Second disk for docker storage
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "${var.docker_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Third disk to carve up for localpersistentvolumes
  ebs_block_device {
    device_name = "/dev/sdc"
    volume_size = "${var.lpv_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  count = "${var.node_count}"

#  security_groups = [ "${aws_security_group.instance.id}" ]
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  subnet_id              = "${aws_subnet.nw-subnet.id}"

  user_data              = "${file("userdata.sh")}"

#  availability_zone = "${element(split(",", var.availability_zones), count.index) }"
#  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "${var.name_prefix}_node${count.index + 1}"
    owner = "${var.owner_tag}"
    expiration = "${var.expiration_tag}"
    purpose = "${var.purpose_tag}"
    KubernetesCluster = "${var.name_prefix}.k8s.local"
  }
}


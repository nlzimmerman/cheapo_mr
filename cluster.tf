provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  #region = "us-east-1"
  region = "us-west-2"
}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "prefix" {
  default = "cheapo_mr"
}
variable "ami" {
  #PV, for old machines
  #default = "ami-0f4cfd64"
  # HVM Instance Store
  #default = "ami-1b4cfd70"
  # HVM EBS-backed
  # default = "ami-0d4cfd66"
  # HVM EBS-backed us-west-2
  default = "ami-d5c5d1e5"
}
variable "key_name" {
  default = "nlz"
}
variable "key_location" {
  default = "~/.ssh/id_rsa"
}
variable "username" {
  default = "ec2-user"
}
variable "instance_type" {
  #default = "m1.xlarge"
  #default = "cc2.8xlarge"
  default = "c4.8xlarge"
}
resource "aws_instance" "spark_master" {
  tags = {
    Name = "${var.prefix}-0"
  }
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  key_name = "${var.key_name}"
  connection {
    user = "${var.username}"
    key_file = "${var.key_location}"
  }
  subnet_id = "${aws_subnet.public_subnet.id}"
  security_groups = ["${aws_security_group.permissive.id}"]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    delete_on_termination = true
  }
  private_ip = "172.17.0.10"
  provisioner "local-exec" {
    command = "tar -cf puppet-${aws_instance.spark_master.id}.tar puppet"
  }
  provisioner "file" {
    source = "puppet-${aws_instance.spark_master.id}.tar"
    destination = "~/puppet.tar"
  }
  provisioner "remote-exec" {
      inline = [
        "tar -xf ~/puppet.tar",
        "rm ~/puppet.tar",
        "sudo yum install -y puppet3",
        "sudo puppet module install puppetlabs-stdlib",
        "sudo puppet apply --modulepath puppet/modules:/etc/puppet/modules puppet/manifests/spark_master.pp"
      ]
  }
  provisioner "local-exec" {
    command = "rm puppet-${aws_instance.spark_master.id}.tar"
  }
}

resource "aws_instance" "spark_worker_1" {
  tags = {
    Name = "${var.prefix}-1"
  }
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  key_name = "${var.key_name}"
  connection {
    user = "${var.username}"
    key_file = "${var.key_location}"
  }
  subnet_id = "${aws_subnet.public_subnet.id}"
  security_groups = ["${aws_security_group.permissive.id}"]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    delete_on_termination = true
  }
  private_ip = "172.17.0.11"
  provisioner "local-exec" {
    command = "tar -cf puppet-${aws_instance.spark_worker_1.id}.tar puppet"
  }
  provisioner "file" {
    source = "puppet-${aws_instance.spark_worker_1.id}.tar"
    destination = "~/puppet.tar"
  }
  provisioner "remote-exec" {
      inline = [
        "tar -xf ~/puppet.tar",
        "rm ~/puppet.tar",
        "sudo yum install -y puppet3",
        "sudo puppet module install puppetlabs-stdlib",
        "sudo puppet apply --modulepath puppet/modules:/etc/puppet/modules puppet/manifests/spark_worker_1.pp"
      ]
  }
  provisioner "local-exec" {
    command = "rm puppet-${aws_instance.spark_worker_1.id}.tar"
  }
}

resource "aws_instance" "spark_worker_2" {
  tags = {
    Name = "${var.prefix}-2"
  }
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  key_name = "${var.key_name}"
  connection {
    user = "${var.username}"
    key_file = "${var.key_location}"
  }
  subnet_id = "${aws_subnet.public_subnet.id}"
  security_groups = ["${aws_security_group.permissive.id}"]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    delete_on_termination = true
  }
  private_ip = "172.17.0.12"
  provisioner "local-exec" {
    command = "tar -cf puppet-${aws_instance.spark_worker_2.id}.tar puppet"
  }
  provisioner "file" {
    source = "puppet-${aws_instance.spark_worker_2.id}.tar"
    destination = "~/puppet.tar"
  }
  provisioner "remote-exec" {
      inline = [
        "tar -xf ~/puppet.tar",
        "rm ~/puppet.tar",
        "sudo yum install -y puppet3",
        "sudo puppet module install puppetlabs-stdlib",
        "sudo puppet apply --modulepath puppet/modules:/etc/puppet/modules puppet/manifests/spark_worker_2.pp"
      ]
  }
  provisioner "local-exec" {
    command = "rm puppet-${aws_instance.spark_worker_2.id}.tar"
  }
}

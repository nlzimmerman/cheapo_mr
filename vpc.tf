resource "aws_vpc" "default" {
  cidr_block = "172.17.0.0/16"
  tags = {
    Name = "${var.prefix}-vpc"
  }

}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "172.17.0.0/24"
  tags = {
    Name = "${var.prefix}-public"
  }
}
resource "aws_security_group" "permissive" {
  name = "${var.prefix}-permissiveSG"
  description = "default SG"
  vpc_id = "${aws_vpc.default.id}"
  ingress = {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # All local traffic is allowed
  ingress = {
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
  }
  # All outbound traffic is allowed
  egress = {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public.id}"
}

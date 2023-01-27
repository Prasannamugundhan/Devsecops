resource "aws_vpc" "devsecops_vpc" {
  cidr_block = "172.16.0.0/16"
  tags = {
    Name = "devsecops_vpc"
  }
}
resource "aws_internet_gateway" "devsecops_igw" {
  vpc_id = aws_vpc.devsecops_vpc.id
  tags = {
    Name = "devsecops_igw"
  }
}
resource "aws_subnet" "devsecops_subnet" {
  vpc_id            = aws_vpc.devsecops_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "devsecops_subnet"
  }
}
resource "aws_subnet" "devsecops_subnet_1" {
  vpc_id            = aws_vpc.devsecops_vpc.id
  cidr_block        = "172.16.11.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "devsecops_subnet"
  }
}

resource "aws_network_interface" "eni" {
  subnet_id   = aws_subnet.devsecops_subnet.id
  private_ips = ["172.16.10.100"]
  tags = {
    Name = "devsecops_eni"
  }
}

resource "aws_route_table" "devsecops_table" {
  vpc_id = "${aws_vpc.devsecops_vpc.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.devsecops_igw.id}"
  }
}

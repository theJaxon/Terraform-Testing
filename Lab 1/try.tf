provider "aws" {
  version = "~> 2.56"
  region     = "us-west-2"
  access_key = ""
  secret_key = ""
}


/*
  VPC
*/
resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "main_vpc"
  }
}

/*
  Public Subnets
*/
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = "${aws_vpc.main_vpc.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-west-2a"

  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = "${aws_vpc.main_vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public_subnet_2"
  }
}



/*
  Private Subnets
*/
resource "aws_subnet" "private_subnet_1" {
  vpc_id     = "${aws_vpc.main_vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2c"

  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = "${aws_vpc.main_vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2d"

  tags = {
    Name = "private_subnet_2"
  }
}

/*
  Internet Gateway
*/
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id     = "${aws_vpc.main_vpc.id}"

  tags = {
    Name = "internet_gateway"
  }
}


/*
  Route Tables
*/
resource "aws_route_table" "public_route_table" {
  vpc_id     ="${aws_vpc.main_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id     = "${aws_vpc.main_vpc.id}"

  tags = {
    Name = "private_route_table"
  }
}

/*
  Link public subnets with public route tables and private subnets with private route tables
*/

resource "aws_route_table_association" "public_association_1" {
  subnet_id      = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "private_association_1" {
  subnet_id      = "${aws_subnet.private_subnet_1.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_route_table_association" "private_association_2" {
  subnet_id      = "${aws_subnet.private_subnet_2.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}




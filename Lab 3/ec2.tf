resource "aws_instance" "aws_public_instance_1" {
  ami           = "${var.ami_id}" # us-west-2
  availability_zone = "us-west-2a"
  instance_type = "${var.instance_type}"
  count = "${var.number_of_instances}"
  key_name = "${aws_key_pair.generated_key.id}"
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_http_traffic.id}",
  "${aws_security_group.allow_bastion_ssh.id}"]


  tags = {
    Name = "aws_public_instance_1"
  }
}

resource "aws_instance" "aws_public_instance_2" {
  ami           = "${var.ami_id}" # us-west-2
  availability_zone = "us-west-2b"
  instance_type = "${var.instance_type}"
  count = "${var.number_of_instances}"
  key_name = "${aws_key_pair.generated_key.id}"
  subnet_id = "${aws_subnet.public_subnet_2.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_http_traffic.id}",
  "${aws_security_group.allow_bastion_ssh.id}"]


  tags = {
    Name = "aws_public_instance_2"
  }
}


resource "aws_instance" "aws_private_instance_1" {
  ami           = "${var.ami_id}" # us-west-2
  availability_zone = "us-west-2c"
  instance_type = "${var.instance_type}"
  count = "${var.number_of_instances}"
  key_name = "${aws_key_pair.generated_key.id}"
  subnet_id = "${aws_subnet.private_subnet_1.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_bastion_ssh.id}"]

  tags = {
    Name = "aws_private_instance_1"
  }
}

resource "aws_instance" "aws_private_instance_2" {
  ami           = "${var.ami_id}" # us-west-2
  availability_zone = "us-west-2c"
  instance_type = "${var.instance_type}"
  count = "${var.number_of_instances}"
  key_name = "${aws_key_pair.generated_key.id}"
  subnet_id = "${aws_subnet.private_subnet_2.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_bastion_ssh.id}"]

  tags = {
    Name = "aws_private_instance_2"
  }
}


/*
    Bastion server
*/

resource "aws_instance" "bastion_server" {
  ami           = "${var.ami_id}" # us-west-2
  availability_zone = "us-west-2a"
  instance_type = "${var.instance_type}"
  count = "${var.number_of_instances}"
  key_name = "${aws_key_pair.generated_key.id}"
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  vpc_security_group_ids = ["${aws_security_group.ssh_connection_allow.id}"]


  tags = {
    Name = "bastion_server"
  }
}

resource "aws_security_group" "allow_http_traffic" {
  name        = "allow_http_traffic"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.main_vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_traffic"
  }
}

resource "aws_security_group" "ssh_connection_allow" {
  name        = "ssh_connection_allow"
  description = "Allow ssh traffic"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh_connection_allow"
  }
}

resource "aws_security_group" "allow_bastion_ssh" {
  name        = "allow_bastion_ssh"
  description = "allow bastion inbound traffic"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.main_vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_bastion_ssh"
  }
}

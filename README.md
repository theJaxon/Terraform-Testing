# Terraform Labs
### Lab 1:
- Make a VPC on AWS 
- 2 public subnets and 2 private subnets each in a different AZ
- An internet gateway for the VPC 
- 2 routing tables (one for private subnets and one for public subnets)
- Backup the state file on an S3 bucket (Terraform backend)

<details><summary>Terraform code for AWS</summary>
<p>

```HCL
/*VPC*/
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
```
</p>
</details>


<details><summary>Terraform State file backup on S3 bucket</summary>
<p>

```HCL
terraform {
  backend "s3" {
    bucket = "theterraformstate"
    key    = "terraform/state_backup/terraform.tfstate"
    region = "us-west-2"
  }
}
```
</p>
</details>

---

### Lab 2:
- 5 EC2s where 2 will be placed in the public subnets (later nginx will be installed on them using ansible) and 2 will be placed in the private subnets, a bastion server will also be placed in the public subnet.
- 2 security groups 
   - one to allow SSH connection on the bastion server by opening port `22`
   - one to allow HTTP connections on the public EC2s by opening port `80`
 <details><summary> Terraform EC2s </summary>
<p>

```HCL
resource "aws_instance" "aws_public_instance_1" {
  ami           = "${var.ami_id}" # us-west-2
  availability_zone = "us-west-2a"
  instance_type = "${var.instance_type}"
  count = "${var.number_of_instances}"
  key_name = "${aws_key_pair.generated_key.id}"
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_http_traffic.id}"]

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
  vpc_security_group_ids = ["${aws_security_group.allow_http_traffic.id}"]


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
```
</p>
</details>



<details><summary>Security groups</summary>
<p>

```HCL

resource "aws_security_group" "allow_http_traffic" {
  name        = "allow_http_traffic"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
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


```

</p>
</details>

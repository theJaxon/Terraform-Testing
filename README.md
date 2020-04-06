# Terraform Labs
[![forthebadge](https://forthebadge.com/images/badges/cc-0.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/powered-by-jeffs-keyboard.svg)](https://forthebadge.com)
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
 <details><summary>:five: EC2s</summary>
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



<details><summary>:lock: Security groups</summary>
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

---

### Lab 3:
- `Dockerfile` that uses [jenkins](https://hub.docker.com/r/jenkins/jenkins/) image as a base then installs `terraform` on it
- A conteiner that uses the previously built image using the Dockerfile
  - `docker build -t jenkinsTerra .`
  - `docker run -p 8080:8080 jenkinsTerra `
  - Open a different vagrant terminal and enter the container to get the password that'll be used for jenkins first run ` docker container exec -it CONTAINER_ID /bin/bash `
- Create a pipeline in jenkins that builds the infrastructure using terraform, a useful resource for linking the AWS credentials with jenkins pipeline using environment variables is this [answer](https://serverfault.com/a/886491)
- Configure ansible on the host (vagrant in my case) to run using the bastion server created earlier, use this [answer](https://serverfault.com/a/1008815) for help.
- Run nginx playbook to configure the 2 public EC2s 


<details><summary>Dockerfile</summary>
<p>

```python
FROM jenkins/jenkins
USER root
WORKDIR /home/
RUN pwd && ls && \
    wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip && \
    pwd && ls && \
    unzip terraform_0.12.24_linux_amd64.zip && \
    pwd && ls && \
    rm terraform_0.12.24_linux_amd64.zip && \
    mv terraform /bin/

EXPOSE 8080
```

</p>
</details>


<details><summary>Jenkinsfile</summary>
<p>

```groovy

pipeline {
   agent any
        stages {

                stage("Terraform init") {
                        steps {
                            sh "cd \"Lab 3\" && pwd && ls && terraform init -var ak=\"${env.AWS_ACCESS_KEY_ID}\" -var sa=\"${env.AWS_SECRET_ACCESS_KEY}\""
                        }
                    }

                stage("Terraform plan") {
                    steps {
                        sh "cd \"Lab 3\" && pwd && ls && terraform plan"
                    }
                }

                stage("Terraform apply") {
                    steps {
                        sh "cd \"Lab 3\" && pwd && ls && terraform apply -auto-approve"
                    }
                }
        }
}
```

</p>
</details>

* In my case i made 3 different jenkinsfiles 
  - one responsible for `init plan and apply`
  - one for generating the graph using `terraform graph`
  - one for destroying
  

<details><summary>JTerraformGraph file</summary>
<p>


```groovy
pipeline {
   agent any
        stages {
            
            stage("Terraform init") {
                        steps {
                            sh "cd \"Lab 3\" && pwd && ls && terraform init -var ak=\"${env.AWS_ACCESS_KEY_ID}\" -var sa=\"${env.AWS_SECRET_ACCESS_KEY}\""
                        }
                    }

                stage("Terraform graph") {
                    steps {
                        sh "cd \"Lab 3\" && pwd && ls && terraform graph"
                    }
                }
        }
}
```

</p>
</details>


<details><summary>JenkinsDestroy</summary>
<p>


```groovy
pipeline {
   agent any
        stages {

                stage("Terraform destroy") {
                    steps {
                        sh "cd \"Lab 3\" && pwd && ls && terraform destroy -auto-approve"
                    }
                }
        }
}
```

</p>
</details>


<details><summary>ansible's nginx playbook</summary>
<p>

```yaml
---
- hosts: Public
  become: true
  user: ec2-user
  vars:
    - ansible_ssh_user: "ec2-user"
    - ansible_ssh_common_args: >
          -o ProxyCommand="ssh -W %h:%p -q {{ ansible_ssh_user }}@54.202.10.158" \
          -o ServerAliveInterval=5 \
          -o StrictHostKeyChecking=no
  tasks:
    - name: epel-release install
      package:
        name: epel-release 
        state: present 
        

    - name: download nginx 
      package:
        name: nginx 
        state: present 
    
    - name: enable nginx 
      systemd:
        name: nginx 
        state: started 
        enabled: yes

```

</p>
</details>

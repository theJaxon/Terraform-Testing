variable "ami_id" {
  default = "ami-0ce21b51cb31a48b8" // Amazon Linux 2 AMI (HVM), SSD Volume Type
}

variable "instance_type" {
  default = "t2.micro"
}

variable "number_of_instances" {
    default = 1
    type = number
}

variable "ak" {

}

variable "sa" {

}



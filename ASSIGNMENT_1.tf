/*ASSIGNMENT-1:

1. CREATE A VPC, SUBNET, IGW, ROUTE-TABLE AND ATTACH TO SERVER.
2. SERVER NEED TO CREATE ON US-EAST-1B AZ.
3. SERVER NEED TO HAVE KEY-PAIR WHICH GENERTED BY TLS PROVIDER.
4. PROVIDER VERSIONS (AWS=5.68.0, TLS=4.0.5, LOCAL=2.5.0)
5. STATEFILE MUST BE ON S3 BUCKET.
6. AFTER CREATING RESOURCE SET BACKEND STATE FILE FROM S3 TO LOCAL.

TERRFORM CODE:*/

# Specify Terraform version and required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.68.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.0"
    }
  }
}
# AWS provider configuration
provider "aws" {
  region = "us-east-1"
}
# Generate a TLS private key
resource "tls_private_key" "example" {
  algorithm = "RSA"
}

# Write the private key to a local file
resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/private_key.pem" # Local path to save the private key
}
#Creating new keypair in aws
resource "aws_key_pair" "keypair" {
  key_name   = "assignment"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
# Create VPC
resource "aws_vpc" "one" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "assignment_vpc"
  }
}
# Create Subnet
resource "aws_subnet" "two" {
  vpc_id            = aws_vpc.one.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "assignment_subnet"
  }
}
# Create Internet Gateway
resource "aws_internet_gateway" "three" {
  vpc_id = aws_vpc.one.id

  tags = {
    Name = "assignment_igw"
  }
}
# Create Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.one.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three.id
  }

  tags = {
    Name = "assignment_route_table"
  }
}
# Associate Route Table with Subnet
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.two.id
  route_table_id = aws_route_table.my_route_table.id
}
# Create an EC2 instance
resource "aws_instance" "my_instance" {
  ami           = "ami-0ebfd941bbafe70c6" # Replace with a valid AMI ID in your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.two.id
  key_name      = "assignment"


  tags = {
    Name = "assignment_ec2"
  }
}

terraform {
  backend "s3" {
    bucket = "assignement0325"
    key    = "terraform.tfstate" #name of the S3 object that will store the state file
    region = "us-east-1"
  }
}


#NOTE:run command:terraform init -migrate-state (to get statefile s3 to local)

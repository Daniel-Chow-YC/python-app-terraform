# Configure the AWS provider
provider "aws" {
  region = "eu-west-1"
}


# create vpc
resource "aws_vpc" "app_vpc" {
  cidr_block =  "10.0.0.0/16"
  tags = {
    Name = var.name
  }
}


# Internet Gateway
resource "aws_internet_gateway" "app_gw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.name} - IG"
  }
}


# Route table
resource "aws_route_table" "app_route" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_gw.id

  }
  tags = {
    Name = "${var.name} - route table"
  }
}


# Route table associations
resource "aws_route_table_association" "app_assoc" {
  subnet_id      = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_route.id
}


# create a subnet
resource "aws_subnet" "app_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-1a"
  tags = {
   Name = var.name
  }
}


# Create a Security Group
resource "aws_security_group" "app_security_group" {
  name        = var.name
  description = "Allow port 80"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

  tags = {
    Name = var.name
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


# Launch an instance
resource "aws_instance" "app_instance" {
  ami                         = var.ami
  subnet_id                   = aws_subnet.app_subnet.id
  vpc_security_group_ids      = [aws_security_group.app_security_group.id]
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  tags = {
    Name = "${var.name} - instance of app"
  }
}

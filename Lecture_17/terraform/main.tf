provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "my-vpc" }
}

# Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "my-subnet" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = { Name = "my-igw" }
}

# Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "my-route-table" }
}

# Route Table Association
resource "aws_route_table_association" "route_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.route_table.id
}

# Security Group for SSH
resource "aws_security_group" "ssh_access" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # будь-хто може підключитись
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # будь-хто може підключитись по 8080
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ssh-access" }
}

# EC2 instance
resource "aws_instance" "my_ec2" {
  ami                         = "ami-0c94855ba95c71c99" # Ubuntu 20.04
  instance_type               = "t2.micro"
  key_name                    = "DEVOPS2025"  # твоє ім’я ключа з AWS
  subnet_id                   = aws_subnet.my_subnet.id
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]

  tags = { Name = "my-ec2" }
}

output "public_ip" {
  value       = aws_instance.my_ec2.public_ip
  description = "Публічна IP-адреса EC2 для підключення по SSH"
}


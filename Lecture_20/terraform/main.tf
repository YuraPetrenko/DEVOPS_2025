provider "aws" {
  region = "us-east-1"
}

# ---------------- VPC ----------------
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "my-vpc" }
}

# ---------------- Subnet ----------------
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "my-subnet" }
}

# ---------------- Internet Gateway ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = { Name = "my-igw" }
}

# ---------------- Route Table ----------------
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "my-route-table" }
}

# ---------------- Route Table Association ----------------
resource "aws_route_table_association" "route_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.route_table.id
}

# ---------------- Security Group ----------------
resource "aws_security_group" "k8s_access" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "k8s-access" }
}

# ---------------- EC2 Instances ----------------
resource "aws_instance" "k8s_nodes" {
  count                       = 2
  ami                         = "ami-0c94855ba95c71c99" # Ubuntu 20.04
  instance_type               = "t2.medium"
  key_name                    = "DEVOPS2025"            # Замінити на свій key pair
  subnet_id                   = aws_subnet.my_subnet.id
  vpc_security_group_ids      = [aws_security_group.k8s_access.id]
  associate_public_ip_address = true

  tags = {
    Name = "k8s-node-${count.index}"
    Role = count.index == 0 ? "master" : "worker"
  }
}

# ---------------- Outputs ----------------
resource "local_file" "ansible_inventory" {
  content = <<EOT
[master]
${aws_instance.k8s_nodes[0].public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/DEVOPS2025.pem

[worker]
${aws_instance.k8s_nodes[1].public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/DEVOPS2025.pem

[k8s:children]
master
worker
EOT

  filename = "${path.module}/inventory.ini"
}


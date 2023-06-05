data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

// Resrc of S.G
resource "aws_security_group" "SG" {
  name        = "ssh-sg"
  description = "Allow SSH traffic from anywhere"
  vpc_id = var.vpc-id
 
  ingress {
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
}

resource "aws_instance" "BastionHost" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = var.public-subnet-id
  vpc_security_group_ids = [aws_security_group.SG.id]
  key_name = "key-bastion"



  tags = {
    Name = "BastionHost"
  }
}
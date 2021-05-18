
data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_eip" "my_static_ip" {
  instance = aws_instance.my_ubuntu.id
  tags = {
    Name  = "WireGuard Server IP"
    Owner = "Ivan Andreev"
  }
}

resource "aws_instance" "my_ubuntu" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.wireguard_server.id]
  key_name               = "lesson-50"
  user_data              = file("script.sh")

  tags = {
    Name  = "WireGuard-server"
    Owner = "Ivan Andreev"
  }
}

resource "aws_security_group" "wireguard_server" {
  name        = "Dynamic security group"
  description = "WireGuard security group"


  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      description = "TLS from VPC"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WireGuard"
  }
}

output "WebServer_public_ip" {
  value = aws_eip.my_static_ip.public_ip
}

# Bastion 서버의 보안 그룹 생성
resource "aws_security_group" "bastion_server_sg" {
    name_prefix = "bastion_server_sg"
    vpc_id = module.vpc.vpc_id 

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "bastion_server_sg"
    }
}

# Bastion 서버의 EIP 생성 및 할당
resource "aws_eip" "bastion_eip" {
  vpc = true
  tags = {
    "Name" = "bastion_eip"
  }
}
resource "aws_eip_association" "eip" {
  instance_id = aws_instance.bastion_server.id
  allocation_id = aws_eip.bastion_eip.id 
}

# Bastion 서버 EC2 인스턴스 생성
resource "aws_instance" "bastion_server" {
    ami = "ami-008d41dbe16db6778"
    instance_type = "t2.micro"
    subnet_id = module.vpc.public_subnets[0]
    vpc_security_group_ids = [aws_security_group.bastion_server_sg.id]
    availability_zone = "${var.region}a"
    key_name = var.bastion_key
    user_data = <<-EOF
              #!/bin/bash
              # AWS CLI 설치
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              aws --version

              # eksctl 설치
              curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
              sudo mv /tmp/eksctl /usr/local/bin
              eksctl version

              # kubectl 설치
              curl -LO "https://dl.k8s.io/release/v1.27.1/bin/linux/amd64/kubectl"
              sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
              kubectl version --short
              EOF
    tags = {
        Name = "bastion_server"
    }
}
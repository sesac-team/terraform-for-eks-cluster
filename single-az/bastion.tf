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

    ingress {
        from_port = 80
        to_port = 80
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

# allow_bastion_access란 이름의 보안그룹 규칙을 추가적으로 구성
# Bastion 서버의 EIP의 접근 허용 EKS 노드 보안그룹
resource "aws_security_group_rule" "allow_bastion_access" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion_server_sg.id
  cidr_blocks       = ["${aws_eip.bastion_eip.public_ip}/32"]
}

# RSA 알고리즘 및 2048 비트의 private key 생성
resource "tls_private_key" "example_pk" {
    algorithm = "RSA"
    rsa_bits = 4096
}

# private key로 key pair 파일 생성
resource "aws_key_pair" "example_kp" {
    key_name = "example_kp"
    public_key = tls_private_key.example_pk.public_key_openssh
}

# 현재 경로에 .pem 파일 다운로드
resource "local_file" "ssh_key" {
    filename = "${aws_key_pair.example_kp.key_name}.pem"
    content = tls_private_key.example_pk.private_key_pem 
    file_permission = "0600"
}

# Bastion 서버 EC2 인스턴스 생성
resource "aws_instance" "bastion_server" {
    ami = "ami-062cf18d655c0b1e8"
    instance_type = "t2.micro"
    subnet_id = module.vpc.public_subnets[0]
    vpc_security_group_ids = [aws_security_group.bastion_server_sg.id]
    availability_zone = "${var.region}a"
    key_name = aws_key_pair.example_kp.key_name
    tags = {
        Name = "bastion_server"
    }
}

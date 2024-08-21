resource "aws_vpc" "fullaccel_seoul" {
    cidr_block = "10.1.0.0/16"
    tags = {
      Name = "fullaccel_seoul"
    }
}

# fullaccel_seoul VPC Public Subnets
resource "aws_subnet" "seoul_public_subnet_2a" {
    vpc_id = aws_vpc.fullaccel_seoul.id
    cidr_block = "10.1.1.0/24"
    availability_zone = "ap-northeast-2a"
    map_public_ip_on_launch = true # 해당 서브넷을 선택해 생성된 인스턴스에 모두 public ip 부여
    tags = {
      Name = "seoul_public_subnet_2a"
    }
}

resource "aws_subnet" "seoul_public_subnet_2c" {
    vpc_id = aws_vpc.fullaccel_seoul.id
    cidr_block = "10.1.2.0/24"
    availability_zone = "ap-northeast-2c"
    map_public_ip_on_launch = true 
    tags = {
      Name = "seoul_public_subnet_2c"
    }
}

# fullaccel_seoul VPC Private Subnets of 2a AZ
resource "aws_subnet" "seoul_private_subnet_2a_1" {
    vpc_id = aws_vpc.fullaccel_seoul.id 
    cidr_block = "10.1.3.0/24"
    availability_zone = "ap-northeast-2a"
    tags = {
        Name = "seoul_private_subnet_2a_1"
    }
}
resource "aws_subnet" "seoul_private_subnet_2a_2" {
    vpc_id = aws_vpc.fullaccel_seoul.id 
    cidr_block = "10.1.4.0/24"
    availability_zone = "ap-northeast-2a"
    tags = {
        Name = "seoul_private_subnet_2a_2"
    }
}

# fullaccel_seoul VPC Private Subnets of 2c AZ
resource "aws_subnet" "seoul_private_subnet_2c_1" {
    vpc_id = aws_vpc.fullaccel_seoul.id 
    cidr_block = "10.1.5.0/24"
    availability_zone = "ap-northeast-2c"
    tags = {
        Name = "seoul_private_subnet_2c_1"
    }
}
resource "aws_subnet" "seoul_private_subnet_2c_2" {
    vpc_id = aws_vpc.fullaccel_seoul.id 
    cidr_block = "10.1.6.0/24"
    availability_zone = "ap-northeast-2c"
    tags = {
        Name = "seoul_private_subnet_2c_2"
    }
}

# fullaccel_seoul Public 라우팅 테이블 & 인터넷 게이트웨이
resource "aws_internet_gateway" "fullaccel_seoul_vpc_IGW" {
  vpc_id = aws_vpc.fullaccel_seoul.id 
  tags = {
    Name = "fullaccel_seoul_vpc_IGW"
  }
}

resource "aws_route_table" "seoul_public_rt" {
    vpc_id = aws_vpc.fullaccel_seoul.id 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.fullaccel_seoul_vpc_IGW.id 
    }
    tags = {
        Name = "seoul_public_rt"
    }
}

resource "aws_route_table_association" "seoul_public_rt_association1" {
    subnet_id = aws_subnet.seoul_public_subnet_2a.id
    route_table_id = aws_route_table.seoul_public_rt.id
}

resource "aws_route_table_association" "seoul_public_rt_association2" {
    subnet_id = aws_subnet.seoul_public_subnet_2c.id
    route_table_id = aws_route_table.seoul_public_rt.id 
}

# NAT 게이트웨이 및 fullaccel_seoul Private 라우팅 테이블
resource "aws_eip" "seoul_nat_ip" {
    vpc = true

    lifecycle {
      create_before_destroy = true
    }
}
resource "aws_nat_gateway" "seoul_nat_gateway" {
    allocation_id = aws_eip.seoul_nat_ip.id
    subnet_id = aws_subnet.seoul_public_subnet_2c.id 
    tags = {
      Name = "seoul_nat_gateway"
    }
}
resource "aws_route_table" "seoul_private_rt" {
    vpc_id = aws_vpc.fullaccel_seoul.id 
    tags = {
        Name = "seoul_private_rt"
    }
}
resource "aws_route_table_association" "seoul_private_rt_association1" {
    subnet_id = aws_subnet.seoul_private_subnet_2a_1.id
    route_table_id = aws_route_table.seoul_private_rt.id 
}

resource "aws_route_table_association" "seoul_private_rt_association2" {
    subnet_id = aws_subnet.seoul_private_subnet_2a_2.id
    route_table_id = aws_route_table.seoul_private_rt.id
}
resource "aws_route_table_association" "seoul_private_rt_association3" {
    subnet_id = aws_subnet.seoul_private_subnet_2c_1.id
    route_table_id = aws_route_table.seoul_private_rt.id 
}

resource "aws_route_table_association" "seoul_private_rt_association4" {
    subnet_id = aws_subnet.seoul_private_subnet_2c_2.id
    route_table_id = aws_route_table.seoul_private_rt.id
}

# private 라우팅 테이블이 모든 ICMP(0.0.0.0/0)와 통신할 때 해당 NAT 게이트웨이를 거치도록 명시적 연결
resource "aws_route" "seoul_private_rt_nat" {
    route_table_id = aws_route_table.seoul_private_rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.seoul_nat_gateway.id 
}
resource "aws_vpc" "fullaccel_seoul" {
    cidr_block = "10.1.0.0/16"
    tags = {
      Name = "seoul"
    }
}

resource "aws_vpc" "sydney" {
    cidr_block = "10.2.0.0/16"
    tags = {
      Name = "sydney"
    }
}

# seoul VPC Public Subnet
resource "aws_subnet" "public_subnet_seoul" {
    vpc_id = aws_vpc.seoul.id
    cidr_block = "10.1.1.0/24"
    availability_zone = "ap-northeast-2a"
    map_public_ip_on_launch = true # 해당 서브넷을 선택해 생성된 인스턴스에 모두 퍼블릭 ip 부여
    tags = {
      Name = "public_subnet"
    }
}

resource "aws_internet_gateway" "fir_vpc_IGW" {
  vpc_id = aws_vpc.fir_vpc.id 
  tags = {
    Name = "fir_vpc_IGW"
  }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.fir_vpc.id 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.fir_vpc_IGW.id 
    }
    tags = {
        Name = "public_route_table"
    }
}

resource "aws_route_table_association" "public_route_table_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id 
}

resource "aws_subnet" "private_subnet1" {
    vpc_id = aws_vpc.fir_vpc.id 
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-northeast-2a"
    tags = {
        Name = "private_subnet1"
    }
}

resource "aws_subnet" "private_subnet2" {
    vpc_id = aws_vpc.fir_vpc.id 
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-northeast-2a"
    tags = {
        Name = "private_subnet2"
    }
}

resource "aws_eip" "nat-ip" {
    vpc = true

    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nat_ip.id
    subnet_id = aws_subnet.public_subnet.id 
    tags = {
      Name = "NAT_gateway"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.fir_vpc.id 
    tags = {
        Name = "private_route_table"
    }
}

resource "aws_route_table_association" "private_route_table_association1" {
    subnet_id = aws_subnet.private_subnet1.id
    route_table_id = aws_route_table.private_route_table.id 
}

resource "aws_route_table_association" "private_route_table_association2" {
    subnet_id = aws_subnet.private_subnet2.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route" "private_route_table_nat" {
    route_table_id = aws_route_table.private_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id 
}
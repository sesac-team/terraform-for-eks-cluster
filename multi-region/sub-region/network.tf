resource "aws_vpc" "fullaccel_sydney" {
    cidr_block = "10.2.0.0/16"
    tags = {
      Name = "fullaccel_sydney"
    }
}

# fullaccel_sydney VPC Public Subnets
resource "aws_subnet" "sydney_public_subnet_2a" {
    vpc_id = aws_vpc.fullaccel_sydney.id
    cidr_block = "10.2.1.0/24"
    availability_zone = "ap-southeast-2a"
    map_public_ip_on_launch = true 
    tags = {
      Name = "sydney_public_subnet_2a"
    }
}

resource "aws_subnet" "sydney_public_subnet_2c" {
    vpc_id = aws_vpc.fullaccel_sydney.id
    cidr_block = "10.2.2.0/24"
    availability_zone = "ap-southeast-2c"
    map_public_ip_on_launch = true 
    tags = {
      Name = "sydney_public_subnet_2c"
    }
}

# fullaccel_sydney VPC Private Subnets of 2a AZ
resource "aws_subnet" "sydney_private_subnet_2a_1" {
    vpc_id = aws_vpc.fullaccel_sydney.id 
    cidr_block = "10.2.3.0/24"
    availability_zone = "ap-northeast-2a"
    tags = {
        Name = "sydney_public_subnet_2a_1"
    }
}
resource "aws_subnet" "sydney_private_subnet_2a_2" {
    vpc_id = aws_vpc.fullaccel_sydney.id 
    cidr_block = "10.2.4.0/24"
    availability_zone = "ap-northeast-2a"
    tags = {
        Name = "sydney_public_subnet_2a_2"
    }
}

# fullaccel_sydney VPC Private Subnets of 2c AZ
resource "aws_subnet" "sydney_private_subnet_2c_1" {
    vpc_id = aws_vpc.fullaccel_sydney.id 
    cidr_block = "10.2.5.0/24"
    availability_zone = "ap-northeast-2c"
    tags = {
        Name = "sydney_public_subnet_2c_1"
    }
}
resource "aws_subnet" "sydney_private_subnet_2c_2" {
    vpc_id = aws_vpc.fullaccel_sydney.id 
    cidr_block = "10.2.6.0/24"
    availability_zone = "ap-northeast-2c"
    tags = {
        Name = "sydney_public_subnet_2c_2"
    }
}

resource "aws_internet_gateway" "fullaccel_sydney_vpc_IGW" {
  vpc_id = aws_vpc.fullaccel_seoul.id 
  tags = {
    Name = "fullaccel_sydney_vpc_IGW"
  }
}

resource "aws_route_table" "sydney_public_rt" {
    vpc_id = aws_vpc.fullaccel_sydney.id 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.fullaccel_sydney_vpc_IGW.id 
    }
    tags = {
        Name = "sydney_public_rt"
    }
}
resource "aws_route_table_association" "sydney_public_rt_association1" {
    subnet_id = aws_subnet.sydney_public_subnet_2a.id
    route_table_id = aws_route_table.sydney_public_rt.id 
}

resource "aws_route_table_association" "sydney_public_rt_association2" {
    subnet_id = aws_subnet.sydney_public_subnet_2c.id
    route_table_id = aws_route_table.sydney_public_rt.id 
}

# NAT 게이트웨이 및 fullaccel_sydney Private 라우팅 테이블
resource "aws_eip" "sydney_nat_ip" {
    vpc = true

    lifecycle {
      create_before_destroy = true
    }
}
resource "aws_nat_gateway" "sydney_nat_gateway" {
    allocation_id = aws_eip.sydney_nat_ip.id
    subnet_id = aws_subnet.sydney_public_subnet_2c.id
    tags = {
      Name = "sydney_nat_gateway"
    }
}
resource "aws_route_table" "sydney_private_rt" {
    vpc_id = aws_vpc.fullaccel_sydney.id 
    tags = {
        Name = "sydney_private_rt"
    }
}
resource "aws_route_table_association" "sydney_private_rt_association1" {
    subnet_id = aws_subnet.sydney_private_subnet_2a_1.id
    route_table_id = aws_route_table.sydney_private_rt.id 
}

resource "aws_route_table_association" "sydney_private_rt_association2" {
    subnet_id = aws_subnet.sydney_private_subnet_2a_1.id
    route_table_id = aws_route_table.sydney_private_rt.id
}
resource "aws_route_table_association" "sydney_private_rt_association3" {
    subnet_id = aws_subnet.sydney_private_subnet_2c_1.id
    route_table_id = aws_route_table.sydney_private_rt.id 
}

resource "aws_route_table_association" "sydney_private_rt_association4" {
    subnet_id = aws_subnet.sydney_private_subnet_2c_2.id
    route_table_id = aws_route_table.sydney_private_rt.id
}

# private 라우팅 테이블이 모든 ICMP(0.0.0.0/0)와 통신할 때 해당 NAT 게이트웨이를 거치도록 명시적 연결
resource "aws_route" "sydney_private_rt_nat" {
    route_table_id = aws_route_table.sydney_private_rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sydney_nat_gateway.id 
}

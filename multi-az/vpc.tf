resource "aws_vpc" "fullaccel_seoul" {
    cidr_block = "10.1.0.0/16"
    tags = {
      Name = "fullaccel_seoul"
    }
}

resource "aws_vpc" "fullaccel_sydney" {
    cidr_block = "10.2.0.0/16"
    tags = {
      Name = "fullaccel_sydney"
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
    availability_zone = "ap-northeast-2a"
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
resource "aws_subnet" "sydney_public_subnet_2a_1" {
    vpc_id = aws_vpc.fullaccel_sydney.id 
    cidr_block = "10.2.3.0/24"
    availability_zone = "ap-northeast-2a"
    tags = {
        Name = "sydney_public_subnet_2a_1"
    }
}
resource "aws_subnet" "sydney_public_subnet_2a_2" {
    vpc_id = aws_vpc.fullaccel_sydney.id 
    cidr_block = "10.2.4.0/24"
    availability_zone = "ap-northeast-2a"
    tags = {
        Name = "sydney_public_subnet_2a_2"
    }
}

# fullaccel_sydney VPC Private Subnets of 2c AZ
resource "aws_subnet" "sydney_public_subnet_2c_1" {
    vpc_id = aws_vpc.fullaccel_sydney.id 
    cidr_block = "10.2.5.0/24"
    availability_zone = "ap-northeast-2c"
    tags = {
        Name = "sydney_public_subnet_2c_1"
    }
}
resource "aws_subnet" "sydney_public_subnet_2c_2" {
    vpc_id = aws_vpc.fullaccel_sydney.id 
    cidr_block = "10.2.6.0/24"
    availability_zone = "ap-northeast-2c"
    tags = {
        Name = "sydney_public_subnet_2c_2"
    }
}

# fullaccel_seoul Route Table & Internet Gateway
resource "aws_internet_gateway" "fullaccel_seoul_vpc_IGW" {
  vpc_id = aws_vpc.fullaccel_seoul.id 
  tags = {
    Name = "fullaccel_seoul_vpc_IGW"
  }
}

resource "aws_route_table" "public_rt_seoul" {
    vpc_id = aws_vpc.fullaccel_seoul.id 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.fullaccel_seoul_vpc_IGW.id 
    }
    tags = {
        Name = "public_rt_seoul"
    }
}

resource "aws_route_table" "public_rt_sydney" {
    vpc_id = aws_vpc.fullaccel_sydney.id 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.fullaccel_sydney.id 
    }
    tags = {
        Name = "public_rt_sydney"
    }
}
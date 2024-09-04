# RDS Subnet Group 생성
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name = "my_db_subnet_group"

  subnet_ids = [
    element(module.vpc.private_subnets, 2),
    element(module.vpc.private_subnets, 3)
    ]

  tags = {
    Name = "my_db_subnet_group"
  }
}

# RDS Security Group 생성 
resource "aws_security_group" "my_db_sg" {
  name = "my_db_sg"
  vpc_id = module.vpc.vpc_id 
  
  ingress {
  description = "Allow postgre SQL DB(5432)"
  from_port = 5432
  to_port = 5432
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
    Name = "my_db_sg"
  }
}

# RDS Cluster 생성
resource "aws_rds_cluster" "my_rds_cluster" {
  cluster_identifier = "fullaccel-rds-cluster" 
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.id 
  vpc_security_group_ids = [aws_security_group.my_db_sg.id]
  engine = "aurora-postgresql" 
  engine_mode = "provisioned"
  engine_version = "14.12"
  availability_zones = ["${var.region}a", "${var.region}c"]
  database_name = "mydatabase"
  master_username = "admin1234"
  master_password = "password"
  skip_final_snapshot = true # RDS 삭제 시 스냅샷 생성하지 않음
  port = 5432
}

# RDS 인스턴스 생성 
resource "aws_rds_cluster_instance" "my_rds_cluster_instance" {
  count = 2 # 총 2개의 인스턴스 생성(Reader/Writer로)
  identifier = "fullaccel-rds-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.my_rds_cluster.id 
  instance_class = "db.r5.large"
  engine = aws_rds_cluster.my_rds_cluster.engine
  engine_version = aws_rds_cluster.my_rds_cluster.engine_version

  # Writer용 인스턴스(count.index == 0)이 반드시 a 가용영역에 배포되도록 지정
  availability_zone = "${var.region}${count.index == 0 ? "a" : "c"}" 
}

# RDS 생성 시 Cluster와 인스턴스 간 엔진 및 버전의 정보가 모두 일치해야 함
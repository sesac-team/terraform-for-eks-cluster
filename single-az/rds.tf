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
  description = "Allow DB(3306)"
  from_port = 3306
  to_port = 3306
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
  cluster_identifier = "my-db-cluster" 
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.id 
  vpc_security_group_ids = [aws_security_group.my_db_sg.id]
  engine = "aurora-mysql"
  engine_mode = "provisioned"
  engine_version = "5.7.mysql_aurora.2.11.1"
  availability_zones = ["${var.region}a", "${var.region}c"]
  database_name = "mydatabase"
  master_username = "admin"
  master_password = "admin1234**"
  skip_final_snapshot = true # RDS 삭제 시 스냅샷 생성하지 않음
  port = 3306
}

# RDS 인스턴스 생성 
resource "aws_rds_cluster_instance" "my_rds_cluster_instance" {
  count = 2 # 총 2개의 인스턴스 생성(Reader/Writer로)
  identifier = "my-rds-cluster-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.my_rds_cluster.id 
  instance_class = "db.t3.small"
  engine = aws_rds_cluster.my_rds_cluster.engine
  engine_version = aws_rds_cluster.my_rds_cluster.engine_version
}

# RDS 생성 시 Cluster와 인스턴스 간 엔진 및 버전의 정보가 모두 일치해야 함
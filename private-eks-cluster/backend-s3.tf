# 백엔드를 로컬이 아닌 원격 관리를 위한 s3 버킷으로 설정
terraform {
    backend "s3" {  
        bucket = "fullaccel-tfstate-bucket"
        key = "terraform.tfstate"
        region = "var.region"
    }
}
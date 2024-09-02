# 로컬이 아닌 원격 관리를 위해 backend를 s3 버킷으로 설정
terraform {
    backend "s3" {  
        bucket = "fullaccel-tfstate-bucket"
        key = "terraform.tfstate"
        region = "ap-northeast-2" # backend 블록에서 변수를 사용해 동적으로 설정할 수 없음
        dynamodb_table = "fullaccel-tfstate-bucket-table"
    }
}
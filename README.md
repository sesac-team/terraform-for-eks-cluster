### AWS 인프라 아키텍처
![AWS Infra Architecture](https://github.com/user-attachments/assets/2ae572c6-721e-4c6f-bd15-1161d8368fa3)


### 총 프로비저닝 15분 이상 소요
- 하드웨어 사양에 따라 상이할 수 있으며 최대 NAT 게이트웨이 2분, RDS 클러스터 및 인스턴스 15분, EKS 클러스터 20분 이상 소요될 수 있습니다.

### 중요 사항
- 프로비저닝을 시작하기 전에, 반드시 **본인의 리전 및 키 페어 파일 이름**을 **variables.tf 파일**의 default값으로 입력한 뒤 사용하세요.
- **variables.tf 파일**에 리전별 Amazon Linux 2023 AMI ID 를 명시해두었으니 주석을 제거하고 사용하세요.

# 디렉토리 사용 안내 
|      디렉토리명           | **private-eks-cluster**                       | **public-eks-cluster**                       |
|------------------|------------------------------------------------------|----------------------------------------------|
| **API 엔드포인트 액세스**  | false <br> 같은 VPC 내 bastion 서버를 통해서만 접근         | true <br> 외부 인터넷망에서 접근                  |


따라서 외부에서도 EKS 클러스터에 작업하고 싶으신 경우 public-eks-cluster 디렉토리만 사용해 주세요.

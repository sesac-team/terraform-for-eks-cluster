# 총 프로비저닝 30분 이상 소요됩니다.

- NAT 게이트웨이: 약 2분
- RDS: 약 15분
- EKS 클러스터: 20분 이상
# 중요 사항
- 프로비저닝을 시작하기 전에, 반드시 **본인의 리전 및 키 페어 파일 이름**을 **variables.tf 파일**의 default값으로 입력한 뒤 사용하세요.
- 리전별 Amazon Linux 2023 AMI ID 를 명시해두었으니 주석 제거하고 사용하세요.

# 디렉토리 사용 안내
- multi-region 디렉토리 사용 금지
- single-region 디렉토리: 외부 인터넷 망에서도 EKS 클러스터 API 엔드포인트에 액세스할 수 있습니다.
- private-eks-single-region 디렉토리: bastion 서버를 통해서만 EKS 클러스터 API 엔드포인트에 액세스할 수 있습니다.

따라서 외부에서도 EKS 클러스터에 작업하고 싶으신 경우, single-region 디렉토리만 사용해 주세요.

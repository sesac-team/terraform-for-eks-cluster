variable "region" {
  description = "The region in which the resources will be created."
  default     = "ap-southeast-2"
}

variable "bastion_key" {
  type = string
  default = "fullaccel_kp"
}

variable "ami_ID" {
  type = string
  # default = "ami-00c79d83cf718a893" # ap-northeast-1 (도쿄) AMI 이미지 ID
  # default = "ami-008d41dbe16db6778" # ap-northeast-2 (서울) AMI 이미지 ID
  # default = "ami-0754d03b26ea44c28" # ap-northeast-3 (오사카) AMI 이미지 ID
  # default = "ami-0d07675d294f17973" # ap-southeast-1 (싱가포르) AMI 이미지 ID 
  default = "ami-01fb4de0e9f8f22a7" # ap-southeast-2 (시드니) AMI 이미지 ID
  # default = "ami-066784287e358dad1" # us-east-1 (버지니아 북부) AMI 이미지 ID
  # default = "ami-0490fddec0cbeb88b" # us-east-2 (오하이오) AMI 이미지 ID
  # default = "ami-04fdea8e25817cd69" # us-west-1 (캘리포니아) AMI 이미지 ID
  # default = "ami-02d3770deb1c746ec" # us-west-2 (오레곤) AMI 이미지 ID 
  description = "specify the AMI ID for the instance in your region"
}
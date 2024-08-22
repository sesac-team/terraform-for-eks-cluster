variable "region" {
  description = "The region in which the resources will be created."
  default     = "ap-northeast-2"
}

variable "bastion_key" {
  type = string
  default = "fullaccel_kp"
}

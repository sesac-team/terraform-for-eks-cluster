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
  #default = "ami-008d41dbe16db6778"
  default = "ami-01fb4de0e9f8f22a7"
  description = "specify the AMI ID for the instance in your region"
}
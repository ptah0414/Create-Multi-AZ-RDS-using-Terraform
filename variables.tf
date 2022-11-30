variable "region" {
  default     = "ap-northeast-1"
  description = "AWS region"
}

variable "db_password" {
  default = "test1234"
  description = "RDS root user password"
  #sensitive   = true
}

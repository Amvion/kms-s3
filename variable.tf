

variable "enable_key_rotation" {
  type        = bool
  description = "Specifies whether key rotation is enabled."
  default     = true
}



variable "name" {
  type        = string
  description = "The display name of the alias. The name must start with the word \"alias\" followed by a forward slash (alias/)."
  default     = "alias/s3"
}

variable "principals_extended" {
  default     = []
  description = "extended for support of AWS principals that do not use the AWS identifier"
}
variable "principals" {
  description = "AWS Principals that can use this KMS key.  Use [\"*\"] to allow all principals."
  default     = []
}


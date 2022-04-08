variable "region" {
  type        = string
  description = "Region to deploy the resources"
}

variable "public_subnets" {
  type        = list(string)
  description = "Define Public Subnets by providing their CIDRs"
}

variable "private_subnets" {
  type        = list(string)
  description = "Define Private Subnets by providing their CIDRs"
}

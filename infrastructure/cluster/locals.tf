locals {
  azs                   = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnet_prefix  = "eks-public"
  private_subnet_prefix = "eks-private"
  eip_prefix            = "eks-eip"
  ngw_prefix            = "eks-ngw"
  rt_prefix             = "eks-rt"
}

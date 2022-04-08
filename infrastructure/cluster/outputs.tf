output "region" {
  value = var.region
}

output "cluster_name" {
  value = module.eks.cluster_id
}

output "ecr_name" {
  value = "${aws_ecr_repository.this.registry_id}.dkr.ecr.${var.region}.amazonaws.com"
}

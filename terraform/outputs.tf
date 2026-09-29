# --------------------------------------------------
# AWS Region
# --------------------------------------------------

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}


# --------------------------------------------------
# VPC
# --------------------------------------------------

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}


# --------------------------------------------------
# Public Subnets
# --------------------------------------------------

output "public_subnet_ids" {

  description = "Public subnet IDs"

  value = {
    for name, subnet in aws_subnet.public :
    name => subnet.id
  }
}


# --------------------------------------------------
# Private Subnets
# --------------------------------------------------

output "private_subnet_ids" {

  description = "Private subnet IDs"

  value = {
    for name, subnet in aws_subnet.private :
    name => subnet.id
  }
}


# --------------------------------------------------
# NAT Gateway
# --------------------------------------------------

output "nat_gateway_id" {

  description = "NAT Gateway ID"

  value = aws_nat_gateway.main.id
}


# --------------------------------------------------
# ECR Repository
# --------------------------------------------------

output "ecr_repository_name" {

  description = "ECR repository name"

  value = aws_ecr_repository.app.name
}


output "ecr_repository_url" {

  description = "ECR repository URL"

  value = aws_ecr_repository.app.repository_url
}


output "ecr_push_policy_arn" {

  description = "ECR push IAM policy ARN"

  value = aws_iam_policy.ecr_push.arn
}


# --------------------------------------------------
# EKS
# --------------------------------------------------

output "eks_cluster_name" {

  description = "EKS cluster name"

  value = aws_eks_cluster.main.name
}


output "eks_cluster_version" {

  description = "EKS Kubernetes version"

  value = aws_eks_cluster.main.version
}


output "eks_cluster_endpoint" {

  description = "EKS Kubernetes API endpoint"

  value = aws_eks_cluster.main.endpoint
}


output "eks_cluster_role_arn" {

  description = "EKS cluster IAM role"

  value = aws_iam_role.eks_cluster.arn
}


output "eks_node_role_arn" {

  description = "EKS worker node IAM role"

  value = aws_iam_role.eks_node.arn
}


output "eks_node_group_name" {

  description = "EKS managed node group"

  value = aws_eks_node_group.main.node_group_name
}


output "vpc_cni_role_arn" {

  description = "VPC CNI IAM role"

  value = aws_iam_role.vpc_cni.arn
}
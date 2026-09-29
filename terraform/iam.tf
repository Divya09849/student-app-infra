# ==================================================
# EKS CLUSTER IAM ROLE
# ==================================================

data "aws_iam_policy_document" "eks_cluster_assume_role" {

  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


resource "aws_iam_role" "eks_cluster" {
  name = "${local.cluster_name}-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-cluster-role"
    }
  )
}


resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

  role = aws_iam_role.eks_cluster.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# ==================================================
# EKS NODE IAM ROLE
# ==================================================

data "aws_iam_policy_document" "eks_node_assume_role" {

  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


resource "aws_iam_role" "eks_node" {
  name = "${local.cluster_name}-node-role"

  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-node-role"
    }
  )
}


resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {

  role = aws_iam_role.eks_node.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role_policy_attachment" "eks_ecr_pull_policy" {

  role = aws_iam_role.eks_node.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}


# ==================================================
# VPC CNI IAM ROLE
# ==================================================

data "aws_iam_policy_document" "vpc_cni_assume_role" {

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]


    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]
    }


    condition {
      test = "StringEquals"

      variable = "${replace(
        aws_eks_cluster.main.identity[0].oidc[0].issuer,
        "https://",
        ""
      )}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }


    condition {
      test = "StringEquals"

      variable = "${replace(
        aws_eks_cluster.main.identity[0].oidc[0].issuer,
        "https://",
        ""
      )}:sub"

      values = [
        "system:serviceaccount:kube-system:aws-node"
      ]
    }
  }
}


resource "aws_iam_role" "vpc_cni" {

  name = "${local.cluster_name}-vpc-cni-role"

  assume_role_policy = data.aws_iam_policy_document.vpc_cni_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-vpc-cni-role"
    }
  )
}


resource "aws_iam_role_policy_attachment" "vpc_cni" {

  role = aws_iam_role.vpc_cni.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
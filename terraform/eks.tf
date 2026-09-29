# ==================================================
# EKS CLUSTER
# ==================================================

resource "aws_eks_cluster" "main" {

  name = local.cluster_name

  role_arn = aws_iam_role.eks_cluster.arn

  version = var.cluster_version


  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"

    bootstrap_cluster_creator_admin_permissions = true
  }


  vpc_config {

    subnet_ids = [
      aws_subnet.private["private-a"].id,
      aws_subnet.private["private-b"].id
    ]


    endpoint_private_access = true

    endpoint_public_access = true


    public_access_cidrs = var.cluster_public_access_cidrs
  }


  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]


  tags = merge(
    local.common_tags,
    {
      Name = local.cluster_name
    }
  )
}


# ==================================================
# VPC CNI ADD-ON
# ==================================================

resource "aws_eks_addon" "vpc_cni" {

  cluster_name = aws_eks_cluster.main.name

  addon_name = "vpc-cni"


  service_account_role_arn = aws_iam_role.vpc_cni.arn


  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "PRESERVE"


  depends_on = [
    aws_iam_role_policy_attachment.vpc_cni
  ]


  tags = local.common_tags
}


# ==================================================
# EKS MANAGED NODE GROUP
# ==================================================

resource "aws_eks_node_group" "main" {

  cluster_name = aws_eks_cluster.main.name

  node_group_name = "${local.cluster_name}-nodegroup"


  node_role_arn = aws_iam_role.eks_node.arn


  subnet_ids = [
    aws_subnet.private["private-a"].id,
    aws_subnet.private["private-b"].id
  ]


  version = aws_eks_cluster.main.version


  instance_types = var.node_instance_types


  ami_type = "AL2023_x86_64_STANDARD"


  capacity_type = "ON_DEMAND"


  disk_size = var.node_disk_size


  scaling_config {

    desired_size = var.node_desired_size

    min_size = var.node_min_size

    max_size = var.node_max_size
  }


  update_config {

    max_unavailable = 1
  }


  labels = {

    environment = var.environment

    "managed-by" = "terraform"
  }


  depends_on = [

    aws_iam_role_policy_attachment.eks_worker_node_policy,

    aws_iam_role_policy_attachment.eks_ecr_pull_policy,

    aws_eks_addon.vpc_cni,

    aws_route.private_nat
  ]


  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-nodegroup"
    }
  )
}
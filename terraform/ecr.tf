# --------------------------------------------------
# ECR Repository
# --------------------------------------------------

resource "aws_ecr_repository" "app" {
  name = "${var.project_name}-app"

  image_tag_mutability = "IMMUTABLE"

  force_delete = true

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-app"
    }
  )
}


# --------------------------------------------------
# IAM Policy Document for CI ECR Push
# --------------------------------------------------

data "aws_iam_policy_document" "ecr_push" {

  statement {
    sid    = "ECRAuthentication"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }


  statement {
    sid    = "PushImage"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      aws_ecr_repository.app.arn
    ]
  }
}


# --------------------------------------------------
# ECR Push IAM Policy
# --------------------------------------------------

resource "aws_iam_policy" "ecr_push" {
  name = "${var.project_name}-${var.environment}-ecr-push"

  description = "Allows CI pipeline to push images to the ECR repository"

  policy = data.aws_iam_policy_document.ecr_push.json

  tags = local.common_tags
}
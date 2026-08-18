data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = {
    Name    = "${var.name}-github-actions-oidc-provider"
    Purpose = "GitHub Actions OIDC provider for ${var.name}"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "assume_role_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.allowed_subjects
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "build" {
  name               = "${var.name}-build-role"
  description        = "build.yml assumes this role to build, scan, and push the Docker image"
  assume_role_policy = data.aws_iam_policy_document.assume_role_trust.json

  tags = {
    Name    = "${var.name}-build-role"
    Purpose = "GitHub Actions CI/CD - image build and push"
  }
}

resource "aws_iam_role" "deploy" {
  name               = "${var.name}-deploy-role"
  description        = "deploy.yml assumes this role to build, push, and deploy the app"
  assume_role_policy = data.aws_iam_policy_document.assume_role_trust.json

  tags = {
    Name    = "${var.name}-deploy-role"
    Purpose = "GitHub Actions CI/CD - application deploys"
  }
}

data "aws_iam_policy_document" "build_permissions" {
  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
    resources = [
      "arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/${var.ecr_repository_name}"
    ]
  }
}

data "aws_iam_policy_document" "deploy_permissions" {
  statement {
    sid       = "ECRAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECSServiceAccess"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices",
    ]
    resources = [
      "arn:aws:ecs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:service/${var.name}-cluster/${var.name}-service"
    ]
  }

  statement {
    sid    = "ECSTaskVisibility"
    effect = "Allow"
    actions = [
      "ecs:ListTasks",
    ]
    resources = [
      "arn:aws:ecs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.name}-cluster"
    ]
  }

  statement {
    sid    = "ECSTaskDescribe"
    effect = "Allow"
    actions = [
      "ecs:DescribeTasks",
    ]
    resources = [
      "arn:aws:ecs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:task/${var.name}-cluster/*"
    ]
  }

  statement {
    sid    = "ECSTaskDefinition"
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
    ]
    resources = ["*"]
  }

  statement {
    sid     = "PassRole"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ecs_task_execution_role_name}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ecs_task_role_name}",
    ]
  }

  statement {
    sid       = "CloudWatchLogs"
    effect    = "Allow"
    actions   = ["logs:DescribeLogGroups"]
    resources = ["*"]
  }
}


resource "aws_iam_policy" "build_permissions" {
  name        = "${var.name}-build-permissions"
  description = "Least-privilege permissions for build.yml to assume"
  policy      = data.aws_iam_policy_document.build_permissions.json
}

resource "aws_iam_role_policy_attachment" "build_permissions" {
  role       = aws_iam_role.build.name
  policy_arn = aws_iam_policy.build_permissions.arn
}

resource "aws_iam_policy" "deploy_permissions" {
  name        = "${var.name}-deploy-permissions"
  description = "Least-privilege permissions for docker.yml: deploy"
  policy      = data.aws_iam_policy_document.deploy_permissions.json
}

resource "aws_iam_role_policy_attachment" "deploy_permissions" {
  role       = aws_iam_role.deploy.name
  policy_arn = aws_iam_policy.deploy_permissions.arn
}

resource "aws_iam_role" "terraform" {
  name               = "${var.name}-terraform-role"
  description        = "Assumed by terraform.yml to plan/apply infra/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_trust.json

  tags = {
    Name    = "${var.name}-terraform-role"
    Purpose = "GitHub Actions CI/CD - infrastructure changes"
  }
}

data "aws_iam_policy_document" "terraform_s3_access" {
  statement {
    sid    = "StateBucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "terraform_s3_access" {
  name        = "${var.name}-terraform-s3-access"
  description = "Read/write access to the Terraform state bucket, scoped to one bucket"
  policy      = data.aws_iam_policy_document.terraform_s3_access.json
}

resource "aws_iam_role_policy_attachment" "terraform_s3_access" {
  role       = aws_iam_role.terraform.name
  policy_arn = aws_iam_policy.terraform_s3_access.arn
}

locals {
  terraform_infra_policies = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess",
  ])
}

resource "aws_iam_role_policy_attachment" "terraform_infra" {
  for_each   = local.terraform_infra_policies
  role       = aws_iam_role.terraform.name
  policy_arn = each.value
}

data "aws_iam_policy_document" "terraform_iam_management" {
  statement {
    sid    = "ManageECSRoles"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:TagRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstancesProfilesForRole",
      "iam:PassRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ecs_task_role_name}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ecs_task_execution_role_name}",
    ]
  }
}

resource "aws_iam_policy" "terraform_iam_management" {
  name        = "${var.name}-terraform-iam-management"
  description = "Scoped replacement for IAMFullAccess - only the two ECS roles"
  policy      = data.aws_iam_policy_document.terraform_iam_management.json
}

resource "aws_iam_role_policy_attachment" "terraform_iam_management" {
  role       = aws_iam_role.terraform.name
  policy_arn = aws_iam_policy.terraform_iam_management.arn
}

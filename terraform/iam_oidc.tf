# Github OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name    = "${var.project_name}-github-oidc"
    Project = var.project_name
  }
}

# Github Actions IAM Role
resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:${var.github_username}/${var.github_repo}:*",
            "repo:${var.github_username}/myweb:*"
          ]
        }
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name    = "${var.project_name}-github-actions-role"
    Project = var.project_name
  }
}

# Github Actions IAM Policy
resource "aws_iam_role_policy" "github_actions_policy" {
  name = "${var.project_name}-github-actions-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TerraformStateAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::inhyup-tfstate-us-west-2",
          "arn:aws:s3:::inhyup-tfstate-us-west-2/*"
        ]
      },
      {
        Sid    = "WebsiteS3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::inhyup.com",
          "arn:aws:s3:::inhyup.com/*"
        ]
      },
      {
        Sid    = "CloudFrontInvalidation"
        Effect = "Allow"
        Action = ["cloudfront:CreateInvalidation"]
        Resource = "arn:aws:cloudfront::950888816014:distribution/E3VJ5I0Y143934"
      },
      {
        Sid    = "TerraformPlanReadOnly"
        Effect = "Allow"
        #checkov:skip=CKV_AWS_355: Read-only actions require wildcard resource
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:GetCertificate",
          "acm:ListTagsForCertificate",
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:ListDistributions",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:ListOriginAccessControls",
          "cloudfront:GetResponseHeadersPolicy",
          "cloudfront:ListResponseHeadersPolicies",
          "iam:GetOpenIDConnectProvider",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets",
          "route53:ListTagsForResource",
          "s3:GetBucketPolicy",
          "s3:GetBucketVersioning",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketOwnershipControls",
          "s3:GetBucketLogging",
          "s3:GetBucketAcl",
          "s3:GetEncryptionConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:GetBucketNotification",
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = "*"
      },
      {
        Sid    = "EC2ReadOnly"
        Effect = "Allow"
        #checkov:skip=CKV_AWS_355: ec2:Describe* does not support resource-level permissions
        Action = [
          "ec2:Describe*",
          "ec2:Get*"
        ]
        Resource = "*"
      }
    ]
  })
}
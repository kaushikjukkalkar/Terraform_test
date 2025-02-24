terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_organizations_organization" "existing" {}

output "organization_id" {
  value = data.aws_organizations_organization.existing.id
}


resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]

  feature_set = "ALL"
}


resource "aws_organizations_organizational_unit" "example" {
  name      = "example"
  parent_id = aws_organizations_organization.example.roots[0].id
}

data "aws_iam_policy_document" "example" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "example" {
  name    = "example"
  content = data.aws_iam_policy_document.example.json
}

resource "aws_organizations_policy_attachment" "account" {
  policy_id = aws_organizations_policy.example.id
  target_id = "123456789012"
}
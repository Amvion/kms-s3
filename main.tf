data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}
data "aws_region" "current" {}



data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "kms:*",
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
      type = "AWS"
    }
    resources = [
      "*",
    ]
    sid = "Enable IAM User Permissions"
  }

  statement {
    actions = [
      "kms:GenerateDataKey*",
    ]
    condition {
      test = "StringLike"
      values = [
        "arn:aws:s3:*:${data.aws_caller_identity.current.account_id}:trail/*",
      ]
      variable = "kms:EncryptionContext:aws:s3:arn"
    }
    principals {
      identifiers = [
        "s3.amazonaws.com",
      ]
      type = "Service"
    }
    resources = [
      "*",
    ]
    sid = "Allow s3 to encrypt logs"
  }

  statement {
    actions = [
      "kms:DescribeKey",
    ]
    principals {
      identifiers = [
        "s3.amazonaws.com",
      ]
      type = "Service"
    }
    resources = [
      "*",
    ]
    sid = "Allow s3 to describe key"
  }
}


resource "aws_kms_key" "s3" {
  
  
  enable_key_rotation     = var.enable_key_rotation
  policy                  = data.aws_iam_policy_document.s3.json

}

resource "aws_kms_alias" "s3" {
  name          = var.name
  target_key_id = aws_kms_key.s3.key_id
}

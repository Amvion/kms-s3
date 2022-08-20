data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}
data "aws_region" "current" {}

# https://docs.aws.amazon.com/kms/latest/developerguide/services-s3.html#s3-customer-cmk-policy

data "aws_iam_policy_document" "s3" {

  policy_id = "key-policy-s3"
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    #checkov:skip=CKV_AWS_109:Root is root
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
    #checkov:skip=CKV_AWS_111:Resource policy
    resources = ["*"]
  }
  dynamic "statement" {
    for_each = range(length(var.principals) > 0 ? 1 : 0)
    content {
      sid = "AllowFull"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.principals
      }
      condition {
        test     = "StringLike"
        variable = "kms:ViaService"
        values   = ["s3.*.amazonaws.com"]
      }
      #checkov:skip=CKV_AWS_111:Resource policy
      resources = ["*"]
    }
  }



  dynamic "statement" {
    for_each = var.principals_extended
    content {
      sid = format("AllowFull-%s-%s", statement.value["type"], join("-", statement.value["identifiers"]))
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      effect = "Allow"
      principals {
        type        = statement.value["type"]
        identifiers = statement.value["identifiers"]
      }
      
      #checkov:skip=CKV_AWS_111:Resource policy
      resources = ["*"]
    }

  }

}

resource "aws_kms_key" "s3" {
  description             = var.description
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  policy                  = data.aws_iam_policy_document.s3.json
  tags                    = var.tags
}

resource "aws_kms_alias" "s3" {
  name          = var.name
  target_key_id = aws_kms_key.s3.key_id
}

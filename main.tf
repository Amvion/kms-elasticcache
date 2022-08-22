data "aws_caller_identity" "current" {
}

data "aws_iam_policy_document" "elasticcache_kms" {
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
        "arn:aws:elasticcache:*:${data.aws_caller_identity.current.account_id}:trail/*",
      ]
      variable = "kms:EncryptionContext:aws:elasticcache:arn"
    }
    principals {
      identifiers = [
        "elasticcache.amazonaws.com",
      ]
      type = "Service"
    }
    resources = [
      "*",
    ]
    sid = "Allow elasticcache to encrypt logs"
  }

  statement {
    actions = [
      "kms:DescribeKey",
    ]
    principals {
      identifiers = [
        "elasticcache.amazonaws.com",
      ]
      type = "Service"
    }
    resources = [
      "*",
    ]
    sid = "Allow elasticcache to describe key"
  }
}

resource "aws_kms_key" "elasticcache" {
  enable_key_rotation = var.enable_key_rotation
  policy              = data.aws_iam_policy_document.elasticcache_kms.json
  
}

resource "aws_kms_alias" "elasticcache" {
  name          = var.name
  target_key_id = aws_kms_key.elasticcache.key_id
}

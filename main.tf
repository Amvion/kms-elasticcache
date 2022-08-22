data "aws_caller_identity" "current" {
}

data "aws_iam_policy_document" "elasticache_kms" {
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
        "arn:aws:elasticache:*:${data.aws_caller_identity.current.account_id}:trail/*",
      ]
      variable = "kms:EncryptionContext:aws:elasticache:arn"
    }
    principals {
      identifiers = [
        "elasticache.amazonaws.com",
      ]
      type = "Service"
    }
    resources = [
      "*",
    ]
    sid = "Allow elasticache to encrypt logs"
  }

  statement {
    actions = [
      "kms:DescribeKey",
    ]
    principals {
      identifiers = [
        "elasticache.amazonaws.com",
      ]
      type = "Service"
    }
    
    resources = [
      "*",
    ]
    sid = "Allow elasticache to describe key"
  }
}

resource "aws_kms_key" "elasticache" {
  enable_key_rotation = var.enable_key_rotation
  policy              = data.aws_iam_policy_document.elasticache_kms.json
  
}

resource "aws_kms_alias" "elasticache" {
  name          = var.name
  target_key_id = aws_kms_key.elasticache.key_id
}

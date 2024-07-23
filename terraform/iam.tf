
resource "aws_iam_role" "flask" {
  name = "flask-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "flask" {
  name = "flask-instance-profile"
  role = aws_iam_role.flask.name
}

# ---------------------------------------------------------------------------------------------------------------------
# SSM Policy
# This will allow us to shell into the instance for debugging using SSM over SSH
# ---------------------------------------------------------------------------------------------------------------------

# data "aws_iam_policy_document" "ssm_policy" {
#   statement {
#     actions = [
#       "ssmmessages:CreateDataChannel",
#       "ssmmessages:OpenControlChannel",
#       "ssmmessages:OpenDataChannel",
#       "ssmmessages:CreateControlChannel"
#     ]
#     effect    = "Allow"
#     resources = ["*"]
#   }
#   statement {
#     effect = "Allow"
#     actions = [
#       "ssm:RegisterManagedInstance",
#     ]
#     resources = ["*"]
#     condition {
#       test     = "StringEquals"
#       values = ["broken-flask"]
#       variable = "aws:RequestTag/Project"
#     }
#   }
# #   statement {
# #     effect = "Allow"
# #     actions = [
# #       "ssmmessages:CreateControlChannel",
# #     ]
# #     resources = ["*"]
# #     condition {
# #       test     = "StringEquals"
# #       values   = ["$${ec2:SourceInstanceARN}"]
# #       variable = "aws:SourceArn"
# #     }
# #  }
#   # Docs on the SSM Agent usage of ec2messages and ssmmessages permissions
#   # https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-setting-up-messageAPIs.html
#   statement {
#     sid = "Ec2messages"
#     actions = [
#       "ec2messages:AcknowledgeMessage",
#       "ec2messages:DeleteMessage",
#       "ec2messages:FailMessage",
#       "ec2messages:GetEndpoint",
#       "ec2messages:GetMessages",
#       "ec2messages:SendReply"
#     ]
#     effect = "Allow"
#     resources = ["*"]
#   }
#   # Figured out least privilege by looking at the ACR docs:
#   # https://docs.aws.amazon.com/service-authorization/latest/reference/list_awssystemsmanager.html#awssystemsmanager-document
#   statement {
#     sid = "SSMConstrainedToInstance"
#     effect = "Allow"
#     actions = [
#       "ssm:DescribeAssociation",
#       "ssm:ListInstanceAssociations",
#       # "ssm:PutInventory",
#       "ssm:UpdateAssociationStatus",
#       "ssm:UpdateInstanceAssociationStatus",
#       "ssm:UpdateInstanceInformation"
#     ]
#     resources = [aws_instance.web.arn]
#   }
#   statement {
#     sid = "SSMDocument"
#     effect = "Allow"
#     actions = [
#       "ssm:GetDocument",
#       "ssm:DescribeDocument",
#     ]
#     resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:document/AWS-RunShellScript"]
#   }
#   statement {
#     sid = "SSMWildcardOnly"
#     # These ones cannot be constrained to a specific instance
#     effect = "Allow"
#     actions = [
#       "ssm:GetManifest",
#       "ssm:ListAssociations",
#       "ssm:GetDeployablePatchSnapshotForInstance",
#     ]
#     resources = ["*"]
#   }
#   # Looks like the encryption info is for SSM logging. I don't think we need that.
# #   statement {
# #     effect = "Allow"
# #     actions = [
# #       "s3:GetEncryptionConfiguration",
# #     ]
# #     resources = ["*"]
# #   }
# }

# resource "aws_iam_role_policy" "ssm_policy" {
#   name   = "flask-policy"
#   role   = aws_iam_role.flask.id
#   policy = data.aws_iam_policy_document.ssm_policy.json
# }

resource "aws_iam_role_policy_attachment" "ssm_manager" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.flask.id
}
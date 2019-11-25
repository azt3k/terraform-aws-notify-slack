# data "aws_iam_policy_document" "assume_role" {
#   count = var.create ? 1 : 0
#   statement {
#     effect = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }
#   }
# }

# data "aws_iam_policy_document" "lambda_basic" {
#   count = var.create ? 1 : 0
#   statement {
#     sid = "AllowWriteToCloudwatchLogs"
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#     ]
#     resources = [aws_cloudwatch_log_group.lambda[count.index].arn]
#   }
#   depends_on = [
#     "aws_cloudwatch_log_group.lambda"
#   ]
# }

# data "aws_iam_policy_document" "lambda" {
#   count = var.kms_key_arn != "" && var.create ? 1 : 0
#   source_json = data.aws_iam_policy_document.lambda_basic[0].json
#   statement {
#     sid = "AllowKMSDecrypt"
#     effect = "Allow"
#     actions = ["kms:Decrypt"]
#     resources = [var.kms_key_arn]
#   }
# }

resource "aws_iam_role" "lambda" {
  count               = var.create ? 1 : 0
  name_prefix         = "${var.lambda_function_name}-"
  tags                = merge(var.tags, var.iam_role_tags)
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda" {
  count       = var.create ? 1 : 0
  name_prefix = "${var.lambda_function_name}-"
  role        = aws_iam_role.lambda[0].id
  depends_on  = [
    "aws_cloudwatch_log_group.lambda"
  ]
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_cloudwatch_log_group.lambda[0].arn}"
    }
  ]
}
EOF
}

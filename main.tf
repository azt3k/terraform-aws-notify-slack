terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.65.0"
    }
  }
}

data "aws_sns_topic" "this" {
  count = !var.create_sns_topic ? 1 : 0
  name  = var.sns_topic_name
}

resource "aws_sns_topic" "this" {
  count = var.create_sns_topic && var.create ? 1 : 0
  name  = var.sns_topic_name
  tags  = merge(var.tags, var.sns_topic_tags)
}

resource "aws_cloudwatch_log_group" "lambda" {
  count             = var.create ? 1 : 0
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id
  tags              = merge(var.tags, var.cloudwatch_log_group_tags)
}

resource "aws_sns_topic_subscription" "sns_notify_slack" {
  count       = var.create ? 1 : 0
  topic_arn   = "${var.create_sns_topic ? aws_sns_topic.this[count.index].arn : data.aws_sns_topic.this[count.index].arn}"
  protocol    = "lambda"
  endpoint    = aws_lambda_function.notify_slack[0].arn
  depends_on  = [
    "aws_lambda_function.notify_slack"
  ]
}

resource "aws_lambda_permission" "sns_notify_slack" {
  count         = var.create ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_slack[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = "${var.create_sns_topic ? aws_sns_topic.this[count.index].arn : data.aws_sns_topic.this[count.index].arn}"
  depends_on    = [
    "aws_lambda_function.notify_slack"
  ]
}

data "null_data_source" "lambda_file" {
  inputs = {
    filename = "${path.module}/functions/notify_slack.py"
  }
}

data "null_data_source" "lambda_archive" {
  inputs = {
    filename = "${path.module}/functions/notify_slack.zip"
  }
}

data "archive_file" "notify_slack" {
  count       = var.create ? 1 : 0
  type        = "zip"
  source_file = data.null_data_source.lambda_file.outputs.filename
  output_path = data.null_data_source.lambda_archive.outputs.filename
}

resource "aws_lambda_function" "notify_slack" {
  count                           = var.create ? 1 : 0
  filename                        = data.archive_file.notify_slack[0].output_path
  function_name                   = var.lambda_function_name
  role                            = aws_iam_role.lambda[0].arn
  handler                         = "notify_slack.lambda_handler"
  source_code_hash                = data.archive_file.notify_slack[0].output_base64sha256
  runtime                         = "python3.10"
  timeout                         = 30
  kms_key_arn                     = var.kms_key_arn
  reserved_concurrent_executions  = var.reserved_concurrent_executions
  tags                            = merge(var.tags, var.lambda_function_tags)
  depends_on                      = ["aws_cloudwatch_log_group.lambda"]

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      SLACK_CHANNEL     = var.slack_channel
      SLACK_USERNAME    = var.slack_username
      SLACK_EMOJI       = var.slack_emoji
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
      last_modified,
    ]
  }
}


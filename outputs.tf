output "this_slack_topic_arn" {
  description = "The ARN of the SNS topic from which messages will be sent to Slack"
  value       = "${var.create_sns_topic && var.create ? element(concat(aws_sns_topic.this.*.arn, [""]), 0) : element(concat(data.aws_sns_topic.this.*.arn, [""]), 0)}"
}

output "lambda_iam_role_arn" {
  description = "The ARN of the IAM role used by Lambda function"
  value       = element(concat(aws_iam_role.lambda.*.arn, [""]), 0)
}

output "lambda_iam_role_name" {
  description = "The name of the IAM role used by Lambda function"
  value       = element(concat(aws_iam_role.lambda.*.name, [""]), 0)
}

output "notify_slack_lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = element(concat(aws_lambda_function.notify_slack.*.arn, [""]), 0)
}

output "notify_slack_lambda_function_name" {
  description = "The name of the Lambda function"
  value       = element(concat(aws_lambda_function.notify_slack.*.function_name, [""]), 0)
}

output "notify_slack_lambda_function_invoke_arn" {
  description = "The ARN to be used for invoking Lambda function from API Gateway"
  value       = element(concat(aws_lambda_function.notify_slack.*.invoke_arn, [""]), 0)
}

output "notify_slack_lambda_function_last_modified" {
  description = "The date Lambda function was last modified"
  value       = element(concat(aws_lambda_function.notify_slack.*.last_modified, [""]), 0)
}

output "notify_slack_lambda_function_version" {
  description = "Latest published version of your Lambda function"
  value       = element(concat(aws_lambda_function.notify_slack.*.version, [""]), 0)
}

output "lambda_cloudwatch_log_group_arn" {
  description = "The Amazon Resource Name (ARN) specifying the log group"
  value       = element(concat(aws_cloudwatch_log_group.lambda.*.arn, [""]), 0)
}

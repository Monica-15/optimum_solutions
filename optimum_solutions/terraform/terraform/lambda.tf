resource "aws_lambda_function" "missing_file_checker" {
  filename         = "lambda_function_payload.zip"
  function_name    = "MissingFileChecker"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  runtime          = "python3.8"
  timeout          = 900
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      BUCKET_NAMES = jsonencode([for b in aws_s3_bucket.agency_buckets : b.id])
    }
  }
}

resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name        = "ScheduleRule"
  description = "Scheduled rule to check for missing files"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule = aws_cloudwatch_event_rule.schedule_rule.name
  target_id = "MissingFileCheckerLambda"
  arn = aws_lambda_function.missing_file_checker.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.missing_file_checker.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_rule.arn
}

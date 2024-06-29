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

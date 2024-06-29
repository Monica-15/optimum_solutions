resource "aws_lambda_function" "missing_file_checker" {
  filename         = "lambda/missing_file_checker.zip"
  function_name    = "MissingFileChecker"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "missing_file_checker.handler"
  runtime          = "python3.8"
  timeout          = 900
  source_code_hash = filebase64sha256("lambda/missing_file_checker.zip")

  environment {
    variables = {
      BUCKET_NAMES = jsonencode([for b in aws_s3_bucket.agency_buckets : b.id])
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "LambdaS3Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.agency_buckets[count.index].id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

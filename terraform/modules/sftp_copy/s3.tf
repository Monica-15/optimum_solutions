resource "aws_s3_bucket" "agency_buckets" {
  count = var.agency_count
  bucket = var.agencies[count.index].bucket_name

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "expire_old_objects"
    enabled = true

    expiration {
      days = 365
    }
  }

  tags = {
    Name = "Agency Data Bucket"
  }
}

resource "aws_s3_bucket_policy" "agency_bucket_policies" {
  count = var.agency_count
  bucket = aws_s3_bucket.agency_buckets[count.index].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.sftp_user_role.arn
        }
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.agency_buckets[count.index].id}/*"
        ]
      }
    ]
  })
}

resource "aws_transfer_server" "sftp" {
  endpoint_type = "PUBLIC"
  identity_provider_type = "SERVICE_MANAGED"
 // region = "eu-west-1"
}

resource "aws_transfer_user" "sftp_users" {
  count           = var.agency_count
  user_name       = var.agencies[count.index].name
  server_id       = aws_transfer_server.sftp.id
  role            = aws_iam_role.sftp_user_role.arn
  home_directory  = "/${var.agencies[count.index].bucket_name}"
}

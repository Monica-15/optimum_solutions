provider "aws" {
  region = "eu-west-1"
}

module "optimum" {
  source = "../modules/sftp_copy"
}

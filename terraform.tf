terraform {
  # TODO S3を設定する方法を調べる
  backend "remote" {}

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

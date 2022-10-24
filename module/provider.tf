provider "aws" {
  region      = var.aws.region
  profile     = var.AWS_SESSION_TOKEN == null ? var.aws.profile : null
  access_key  = var.AWS_SESSION_TOKEN == null ? null : var.AWS_SESSION_ACCESSKEY
  secret_key  = var.AWS_SESSION_TOKEN == null ? null : var.AWS_SESSION_SECRETKEY
  token       = var.AWS_SESSION_TOKEN == null ? null : var.AWS_SESSION_TOKEN
}
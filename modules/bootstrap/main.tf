terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.97.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "this" {
  byte_length = 8
}
resource "aws_s3_bucket" "this" {
  bucket = "bootstrap-${random_id.this.hex}"
  acl    = "private"
}

resource "aws_s3_bucket_object" "prefixes" {
  for_each = toset([
    "config/",
    "content/",
    "software/",
    "license/"
  ])

  bucket  = aws_s3_bucket.this.id
  key     = each.value
  content = "/dev/null"
}

resource "aws_s3_bucket_object" "bootstrap" {
  bucket = aws_s3_bucket.this.id
  key    = "config/bootstrap.xml"
  source = "./pan-fw-running-config.xml"
}

resource "aws_s3_bucket_object" "init_cfg" {
  bucket = aws_s3_bucket.this.id
  key    = "config/init-cfg.txt"
  source = "./init-cfg.txt"
}

resource "aws_iam_role" "this" {
  name = "panbootstraprole-${random_id.this.hex}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
  name = "panbootstraprolepolicy-${random_id.this.hex}"
  role = aws_iam_role.this.id

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.this.bucket}"
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "this" {
  name = "panbootstraprole-${random_id.this.hex}"
  role = aws_iam_role.this.name
  path = "/"
}
###########################################
################## AWS ####################
###########################################
locals {
  resource_prefix = "${var.global_prefix}${random_string.random_string2.result}"
  bucket_games = "%{ if var.s3_bucket_name != "" }${var.s3_bucket_name}%{ else }${var.global_prefix}${random_string.random_string.result}%{ endif }"
  s3_origin_id     = "S3-${aws_s3_bucket.games.bucket}"
  api_gw_origin_id = "API-GW-${aws_api_gateway_rest_api.event_handler_api.id}"
  ssm_parameter_name = "${local.resource_prefix}-ssm-origin"
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_string" "random_string" {
  length = 8
  special = false
  upper = false
  lower = true
  numeric = false
}

resource "random_string" "random_string2" {
  length = 2
  special = false
  upper = false
  lower = true
  numeric = false
}

resource "aws_s3_bucket" "games" {
  bucket = local.bucket_games
  
}

resource "aws_s3_bucket_public_access_block" "games" {
  bucket = aws_s3_bucket.games.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "games" {
  bucket = aws_s3_bucket.games.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.games]

  bucket = aws_s3_bucket.games.id
  acl    = "private"
}

data "aws_iam_policy_document" "policy_cloudfront_private_content" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.games.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
     condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_cloudfront_distribution.games.arn
      ]
    }
  }
}

/*
data "aws_iam_policy_document" "games_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.games.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.games.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}*/

resource "aws_s3_bucket_policy" "games" {
  bucket = "${aws_s3_bucket.games.id}"
  policy = "${data.aws_iam_policy_document.policy_cloudfront_private_content.json}"
}



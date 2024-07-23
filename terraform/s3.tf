resource "aws_s3_bucket" "alb_logs" {
  #checkov:skip=CKV_AWS_144:This bucket doesn't need cross region replication
  #checkov:skip=CKV_AWS_18:S3 Server Access logging is not necessary on this ALB Access log bucket
  #checkov:skip=CKV_AWS_21:Bucket versioning is not necessary on Access log buckets
  #checkov:skip=CKV2_AWS_61:The lifecycle configuration block is actually deprecated here and should be removed from Checkov.
  #checkov:skip=CKV_AWS_145:KMS Encryption for an access logs bucket is unnecessary
  #checkov:skip=CKV2_AWS_62:Event notifications are not necessary for this bucket
  bucket = "${var.name}-${data.aws_caller_identity.current.account_id}-${var.region}"
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.bucket
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}


data "aws_iam_policy_document" "alb_logs_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.alb_logs.arn,
      "${aws_s3_bucket.alb_logs.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_elb_logging" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.alb_logs_policy.json
}

output "bootstrap_bucket_name" {
  value = aws_s3_bucket.this.bucket
}
output "bootstrap_iam_role" {
  value = aws_iam_role.this.name
}

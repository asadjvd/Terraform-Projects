output "bucket_name" {
  value = aws_s3_bucket.flask_app.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.flask_app.arn
}
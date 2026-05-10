resource "random_id" "bucket_suffix" {
  byte_length = var.bucket_suffix
}

resource "aws_s3_bucket" "flask_app" {
  bucket = "${var.bucket_name}-${random_id.bucket_suffix.hex}"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-flask-bucket"
    }
  )
}

resource "aws_s3_bucket_versioning" "flask_versioning" {
  bucket = aws_s3_bucket.flask_app.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "flask_block_public" {
  bucket = aws_s3_bucket.flask_app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "flask_files" {
  for_each = fileset("${path.root}/../../flask", "**/*")

  bucket = aws_s3_bucket.flask_app.id
  key    = "flask/${each.value}"
  source = "${path.root}/../../flask/${each.value}"
  etag   = filemd5("${path.root}/../../flask/${each.value}")
  content_type = lookup({
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    ico  = "image/x-icon"
    json = "application/json"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "binary/octet-stream")
}


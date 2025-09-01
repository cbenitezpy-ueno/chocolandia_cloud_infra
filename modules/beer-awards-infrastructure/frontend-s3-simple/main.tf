# S3 Static Website for Beer Awards Frontend - ULTRA SIMPLE
# No CloudFront for cost optimization

# S3 Bucket for static website hosting
resource "aws_s3_bucket" "frontend" {
  bucket        = var.bucket_name
  force_destroy = true  # Allow destruction with objects (dev only)

  tags = var.tags
}

# S3 Bucket Public Access Block - Allow public read for website
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy for public read access
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }

  # SPA routing - redirect all 404s to index.html
  routing_rule {
    condition {
      http_error_code_returned_equals = "404"
    }
    redirect {
      replace_key_with = "index.html"
    }
  }
}

# S3 Bucket CORS Configuration for API calls
resource "aws_s3_bucket_cors_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Default index.html file
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  content_type = "text/html"
  
  content = templatefile("${path.module}/templates/index.html", {
    backend_url = var.backend_url
    app_name    = "${var.name_prefix}-frontend"
  })

  tags = var.tags
}

# Default 404.html file
resource "aws_s3_object" "error_404" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "404.html"
  content_type = "text/html"
  
  content = templatefile("${path.module}/templates/404.html", {
    app_name = "${var.name_prefix}-frontend"
    countdown = "5"
  })

  tags = var.tags
}

# Health check file for ALB
resource "aws_s3_object" "health" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "health.json"
  content_type = "application/json"
  
  content = jsonencode({
    status    = "ok"
    service   = "${var.name_prefix}-frontend"
    timestamp = formatdate("RFC3339", timestamp())
    backend   = var.backend_url
  })

  tags = var.tags
}
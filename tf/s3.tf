resource "aws_s3_bucket" "avg-tf-bucket" {
  bucket = "avg-tf-bucket" 
  force_destroy = true
  tags = {
    Name = "propriedade"
    Environment = "aula"
  }
}

resource "aws_s3_bucket_versioning" "versioning-tf-config" {
  bucket = aws_s3_bucket.avg-tf-bucket.id
  versioning_configuration {
    status = "Enable"
  }
}

resource "aws_s3_bucket_public_access_block" "public-access-tf-bucket" {
  bucket = aws_s3_bucket.avg-tf-bucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "tf-bucket-policy" {
  bucket = aws_s3_bucket.avg-tf-bucket.id

  policy = jsondecode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Actio = ["s3:GetObject",
                 "s3:PutObject",
                 "s3:DeleteObject"],
        Resource = "${aws_s3_bucket.avg-tf-bucket.arn}/*",
      },
    ],
  })
}
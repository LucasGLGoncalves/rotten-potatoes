resource "aws_s3_bucket" "{
  bucket = "avg-tf-bucket"

  tags = {
    Name = ""
    Environment = ""
  }
}

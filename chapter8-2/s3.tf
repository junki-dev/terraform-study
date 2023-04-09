resource "aws_s3_bucket" "main" {
      bucket = "inflearn-terraform-joa-s3"
      tags = {
            Name = "inflearn-terraform-joa-s3"
      }
}
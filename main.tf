resource "aws_s3_bucket" "s3demo-poc-srcbucket" {
  bucket = "s3demo-poc-srcbucket"
  acl    = "public-read-write"

  tags = {
    Name        = "Src Bucket"
    Environment = "Dev"
  }

  versioning {
    enabled = true

  }


  lifecycle_rule {
    id      = "rule1"
    prefix  = "tmp/"
    enabled = true

    expiration {
      days  = 30
    }
    # transition {
    #   days          = 15
    #   storage_class = "STANDARD_IA"
    # }
  }
}

# Destination S3 bucket
resource "aws_s3_bucket" "s3demo2-poc-destbucket" {
  bucket = "s3demo2-poc-destbucket"
  acl    = "public-read-write"

  tags = {
    Name        = "Destination bucket"
    Environment = "Dev"
  }

  versioning {
    enabled = true

  }
}

# Adding an S3 event
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3demo-poc-srcbucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "*"
    filter_suffix       = ".txt"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# Lambda function permission on s3 
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3demo-poc-srcbucket.arn
}

# Lambda function which will be invoked
resource "aws_lambda_function" "func" {
  filename      = "lambda_func.zip"
  function_name = "lambda_func"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_handler"
  runtime       = "python3.6"
  timeout       = "900"
}

# Lambda role 
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

###########
# output of lambda arn
###########
output "arn" {

value = "${aws_lambda_function.func.arn}"

}
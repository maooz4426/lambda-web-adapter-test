resource "aws_lambda_function" "lambda-web-adapter" {
  function_name = "lambda-web-adapter"
  image_uri = "${aws_ecr_repository.lambda-web-adapter.repository_url}:latest"
  role          = aws_iam_role.iam_for_lambda.arn
  package_type  = "Image"
  architectures = ["arm64"]
}

resource "aws_lambda_function_url" "test_latest" {
  function_name      = aws_lambda_function.lambda-web-adapter.function_name
  authorization_type = "NONE"
}


resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
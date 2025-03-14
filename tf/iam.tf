resource "aws_iam_openid_connect_provider" "token_actions_github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

}

resource "aws_iam_role" "from_github_lambda_web_adapter_test" {
  name = "from_github_lambda_web_adapter_test"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": aws_iam_openid_connect_provider.token_actions_github.arn
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:maooz4426/lambda-web-adapter-test:ref:refs/heads/*"
                }
            }
        }
    ]
})


}


resource "aws_iam_role_policy" "lambda_web_adapter_test" {
  name = "lambda_web_adapter_test"
  role = aws_iam_role.from_github_lambda_web_adapter_test.id

  policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": "ecr:GetAuthorizationToken",
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecr:UploadLayerPart",
				"ecr:PutImage",
				"ecr:InitiateLayerUpload",
				"ecr:CompleteLayerUpload",
				"ecr:BatchGetImage",
				"ecr:BatchCheckLayerAvailability"
			],
			"Resource": aws_ecr_repository.lambda-web-adapter.arn
		},
		{
			"Effect": "Allow",
			"Action": "lambda:UpdateFunctionCode",
			"Resource": "*"
		}
	]
})
}
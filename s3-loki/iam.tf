resource "aws_iam_role" "loki" {
  name               = "LokiStorage"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {}
}

resource "aws_iam_policy" "loki" {
  name        = "LokiStorageAccessPolicy"
  path        = "/"
  description = "Allows Loki to access bucket"

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Action: [
		"s3:ListBucket",
		"s3:PutObject",
		"s3:GetObject",
		"s3:DeleteObject"
	    ],
            Resource: [
		    "arn:aws:s3:::${local.bucket_name}",
		    "arn:aws:s3:::${local.bucket_name}/*"
	    ]
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "loki-attach" {

  role       = aws_iam_role.loki.name
  policy_arn = aws_iam_policy.loki.arn
}
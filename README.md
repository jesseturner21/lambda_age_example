# Age Prediction Lambda Function

A simple AWS Lambda function that predicts age based on a name using the [Agify API](https://agify.io/).

## What it does

Send a name, get back an age prediction with confidence data.

**Example:**
- Input: `{"name": "michael"}`
- Output: `{"name": "michael", "age": 62, "count": 233482}`

## Prerequisites

- AWS CLI installed ([install guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- AWS account configured: `aws configure`
- Basic IAM permissions to create Lambda functions

## Quick Deploy

### Option 1: Automated Script (Recommended)

```bash
git clone <your-repo-url>
cd <repo-name>
chmod +x deploy.sh
./deploy.sh
```

That's it! The script handles everything: creating the IAM role, packaging, deploying, and testing.

### Option 2: Manual Commands

### 1. Clone this repo

```bash
git clone <your-repo-url>
cd <repo-name>
```

### 2. Create a ZIP package

```bash
zip function.zip lambda_function.py
```

### 3. Create an IAM role for Lambda

```bash
aws iam create-role \
  --role-name agify-lambda-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'
```

### 4. Attach basic execution policy

```bash
aws iam attach-role-policy \
  --role-name agify-lambda-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

### 5. Deploy the Lambda function

```bash
aws lambda create-function \
  --function-name agify-age-predictor \
  --runtime python3.12 \
  --role arn:aws:iam::<YOUR_ACCOUNT_ID>:role/agify-lambda-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip
```

**Note:** Replace `<YOUR_ACCOUNT_ID>` with your AWS account ID. Find it with:
```bash
aws sts get-caller-identity --query Account --output text
```

## Test it

```bash
aws lambda invoke \
  --function-name agify-age-predictor \
  --payload '{"name": "sarah"}' \
  response.json && cat response.json
```

## Update the function

After making changes:

```bash
zip function.zip lambda_function.py
aws lambda update-function-code \
  --function-name agify-age-predictor \
  --zip-file fileb://function.zip
```

## Clean up

Remove everything when you're done:

```bash
aws lambda delete-function --function-name agify-age-predictor
aws iam detach-role-policy \
  --role-name agify-lambda-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name agify-lambda-role
```

## Troubleshooting

**"Role not found" error:** Wait 10-15 seconds after creating the role before deploying the Lambda function. IAM roles need time to propagate.

**Permission denied:** Make sure your AWS CLI is configured with credentials that have Lambda and IAM permissions.

## License

MIT

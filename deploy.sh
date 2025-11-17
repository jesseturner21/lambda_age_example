#!/bin/bash

# Deploy Agify Lambda Function
# This script automates the deployment of the age prediction Lambda function

set -e  # Exit on any error

echo "🚀 Starting Lambda deployment..."

# Configuration
FUNCTION_NAME="agify-age-predictor"
ROLE_NAME="agify-lambda-role"
RUNTIME="python3.12"

# Get AWS Account ID
echo "📋 Getting AWS account ID..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "   Account ID: $ACCOUNT_ID"

# Create ZIP package
echo "📦 Creating deployment package..."
zip -q function.zip lambda_function.py
echo "   ✓ function.zip created"

# Check if role exists
echo "🔐 Setting up IAM role..."
if aws iam get-role --role-name $ROLE_NAME 2>/dev/null; then
    echo "   ✓ Role $ROLE_NAME already exists"
else
    echo "   Creating role $ROLE_NAME..."
    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document '{
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {"Service": "lambda.amazonaws.com"},
                "Action": "sts:AssumeRole"
            }]
        }' > /dev/null
    
    echo "   Attaching execution policy..."
    aws iam attach-role-policy \
        --role-name $ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
    
    echo "   ⏳ Waiting for role to propagate (15 seconds)..."
    sleep 15
    echo "   ✓ Role created and ready"
fi

ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"

# Check if function exists
echo "⚡ Deploying Lambda function..."
if aws lambda get-function --function-name $FUNCTION_NAME 2>/dev/null; then
    echo "   Function exists, updating code..."
    aws lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file fileb://function.zip > /dev/null
    echo "   ✓ Function updated"
else
    echo "   Creating new function..."
    aws lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime $RUNTIME \
        --role $ROLE_ARN \
        --handler lambda_function.lambda_handler \
        --zip-file fileb://function.zip > /dev/null
    echo "   ✓ Function created"
fi

# Test the function
echo "🧪 Testing function..."
aws lambda invoke \
    --function-name $FUNCTION_NAME \
    --payload '{"name": "alex"}' \
    response.json > /dev/null

if [ -f response.json ]; then
    echo "   ✓ Test response:"
    cat response.json
    echo ""
    rm response.json
fi

# Clean up
rm function.zip

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Function name: $FUNCTION_NAME"
echo "Function ARN: arn:aws:lambda:$(aws configure get region):$ACCOUNT_ID:function:$FUNCTION_NAME"
echo ""
echo "Test it with:"
echo "  aws lambda invoke --function-name $FUNCTION_NAME --payload '{\"name\": \"sarah\"}' response.json && cat response.json"

#!/bin/bash
# Histoday CloudFormation deployment script
set -e

STACK_VPC=histoday-vpc
STACK_S3=histoday-s3
STACK_EC2=histoday-ec2
KEY_NAME=my-key

# Deploy VPC stack
echo "Creating VPC stack..."
aws cloudformation create-stack \
  --stack-name $STACK_VPC \
  --template-body file://cloudformation/vpc.yml \
  --capabilities CAPABILITY_NAMED_IAM

echo "Waiting for VPC stack to complete..."
aws cloudformation wait stack-create-complete --stack-name $STACK_VPC

echo "VPC stack created."

# Deploy S3 stack
echo "Creating S3 stack..."
aws cloudformation create-stack \
  --stack-name $STACK_S3 \
  --template-body file://cloudformation/s3.yml \
  --capabilities CAPABILITY_NAMED_IAM

echo "Waiting for S3 stack to complete..."
aws cloudformation wait stack-create-complete --stack-name $STACK_S3

echo "S3 stack created."

# Deploy EC2 stack
echo "Creating EC2 stack..."
aws cloudformation create-stack \
  --stack-name $STACK_EC2 \
  --template-body file://cloudformation/ec2.yml \
  --parameters ParameterKey=KeyName,ParameterValue=$KEY_NAME \
  --capabilities CAPABILITY_NAMED_IAM

echo "Waiting for EC2 stack to complete..."
aws cloudformation wait stack-create-complete --stack-name $STACK_EC2

echo "EC2 stack created successfully."

# Show outputs
echo "--- EC2 Instance Info ---"
aws cloudformation describe-stacks --stack-name $STACK_EC2 --query "Stacks[0].Outputs" --output table

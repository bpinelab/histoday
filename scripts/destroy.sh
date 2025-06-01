#!/bin/bash
# Histoday CloudFormation teardown script
set -e

STACK_EC2=histoday-ec2
STACK_S3=histoday-s3
STACK_VPC=histoday-vpc
LOG_FILE=destroy.log

# Confirm execution
read -p "Are you sure you want to delete all Histoday stacks and S3 data? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborted by user."
  exit 1
fi

# Redirect output to log file
exec > >(tee -a $LOG_FILE) 2>&1

# Load bucket name from .env if exists
if [ -f .env ]; then
  echo "Loading bucket name from .env..."
  export $(grep -v '^#' .env | xargs)
fi

BUCKET_NAME=${HISTODAY_BUCKET:-histoday-public-youraccountid}

# Delete EC2 stack
echo "Deleting EC2 stack..."
aws cloudformation delete-stack --stack-name $STACK_EC2
aws cloudformation wait stack-delete-complete --stack-name $STACK_EC2
echo "EC2 stack deleted."

# Empty and delete S3 bucket
echo "Emptying and deleting S3 bucket ($BUCKET_NAME)..."
aws s3 rm s3://$BUCKET_NAME --recursive || echo "Bucket may already be empty or not exist."
aws cloudformation delete-stack --stack-name $STACK_S3
aws cloudformation wait stack-delete-complete --stack-name $STACK_S3
echo "S3 stack deleted."

# Delete VPC stack
echo "Deleting VPC stack..."
aws cloudformation delete-stack --stack-name $STACK_VPC
aws cloudformation wait stack-delete-complete --stack-name $STACK_VPC
echo "VPC stack deleted."

echo "All stacks and resources have been successfully removed."

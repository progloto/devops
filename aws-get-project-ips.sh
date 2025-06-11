#!/bin/bash

AWSCLI="aws  --profile kaymera-it"
# Get a list of all $AWSCLI regions
regions=$($AWSCLI ec2 describe-regions --query "Regions[].RegionName" --output text)

# Loop through each region
for region in $regions; do
  echo "Region: $region"

  # Get Elastic IPs
  echo "  Elastic IPs:"
  $AWSCLI ec2 describe-addresses --region "$region" --query "Addresses[*].[PublicIp]" --output text

  # Get EC2 instance public IPs
  echo "  Instance Public IPs:"
  $AWSCLI ec2 describe-instances --region "$region" --query "Reservations[].Instances[].PublicIpAddress" --output text

  echo "" # Add an empty line for better readability
done


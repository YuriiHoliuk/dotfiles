#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [--access-key ACCESS_KEY] [--secret-key SECRET_KEY] [--region REGION] [--output FORMAT]"
    echo "Or set environment variables:"
    echo "  AWS_ACCESS_KEY_ID"
    echo "  AWS_SECRET_ACCESS_KEY"
    echo "  AWS_DEFAULT_REGION"
    echo "  AWS_DEFAULT_OUTPUT"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --access-key)
            AWS_ACCESS_KEY_ID="$2"
            shift 2
            ;;
        --secret-key)
            AWS_SECRET_ACCESS_KEY="$2"
            shift 2
            ;;
        --region)
            AWS_DEFAULT_REGION="$2"
            shift 2
            ;;
        --output)
            AWS_DEFAULT_OUTPUT="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if credentials are provided
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo -e "${RED}Error: AWS credentials are required${NC}"
    usage
fi

# Set default values if not provided
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-"eu-central-1"}
AWS_DEFAULT_OUTPUT=${AWS_DEFAULT_OUTPUT:-"json"}

# Configure AWS CLI
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set region "$AWS_DEFAULT_REGION"
aws configure set output "$AWS_DEFAULT_OUTPUT"

echo -e "${GREEN}AWS CLI has been configured successfully!${NC}"
echo "You can verify your configuration by running: aws configure list" 
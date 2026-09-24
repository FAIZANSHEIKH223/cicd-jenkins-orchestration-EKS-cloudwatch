#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"
BUILD_NUMBER="${2:-}"

if [[ -z "$ENVIRONMENT" || -z "$BUILD_NUMBER" ]]; then
    echo "Usage: $0 <environment> <build-number>"
    exit 1
fi

case "$ENVIRONMENT" in
    dev)
        ECR_REPOSITORY="practice1"
        ;;
    qa)
        ECR_REPOSITORY="practice1-qa"
        ;;
    stage)
        ECR_REPOSITORY="practice1-stage"
        ;;
    prod)
        ECR_REPOSITORY="practice1-prod"
        ;;
    *)
        echo "ERROR: Invalid environment."
        exit 1
        ;;
esac

AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
    --query Account \
    --output text)

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

IMAGE_NAME="practice1:${BUILD_NUMBER}"

REMOTE_IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY}:${BUILD_NUMBER}"

echo "=========================================="
echo "ECR Configuration"
echo "=========================================="
echo "AWS Account  : $AWS_ACCOUNT_ID"
echo "Region       : $AWS_REGION"
echo "Repository   : $ECR_REPOSITORY"
echo "Image        : $REMOTE_IMAGE"
echo "=========================================="

echo "Logging in to Amazon ECR..."

aws ecr get-login-password \
    --region "$AWS_REGION" |
    docker login \
        --username AWS \
        --password-stdin "$ECR_REGISTRY"

echo "Tagging Docker image..."

docker tag \
    "$IMAGE_NAME" \
    "$REMOTE_IMAGE"

echo "Pushing Docker image..."

docker push "$REMOTE_IMAGE"

echo "Verifying image..."

aws ecr describe-images \
    --repository-name "$ECR_REPOSITORY" \
    --image-ids imageTag="$BUILD_NUMBER" \
    --region "$AWS_REGION"

echo "ECR push completed successfully."

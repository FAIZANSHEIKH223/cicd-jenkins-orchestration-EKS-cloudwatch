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

IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY}:${BUILD_NUMBER}"

echo "=========================================="
echo "Kubernetes Deployment"
echo "=========================================="
echo "Environment : $ENVIRONMENT"
echo "Namespace   : $K8S_NAMESPACE"
echo "Deployment  : $K8S_DEPLOYMENT"
echo "Image       : $IMAGE"
echo "=========================================="

echo "Applying namespace..."

kubectl apply \
    -f k8s/namespace.yaml

echo "Preparing deployment manifest..."

sed \
    "s|IMAGE_PLACEHOLDER|${IMAGE}|g" \
    k8s/deployment.yaml \
    > k8s/deployment.generated.yaml

echo "Applying deployment..."

kubectl apply \
    -f k8s/deployment.generated.yaml

echo "Applying service..."

kubectl apply \
    -f k8s/service.yaml

echo "Waiting for rollout..."

kubectl rollout status \
    deployment/"$K8S_DEPLOYMENT" \
    -n "$K8S_NAMESPACE" \
    --timeout=5m

echo "Deployment applied successfully."

echo "Current pods:"

kubectl get pods \
    -n "$K8S_NAMESPACE" \
    -o wide

echo "Current service:"

kubectl get service \
    "$K8S_SERVICE" \
    -n "$K8S_NAMESPACE"

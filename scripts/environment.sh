#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"

if [[ -z "$ENVIRONMENT" ]]; then
    echo "ERROR: Environment was not provided."
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
        echo "ERROR: Invalid environment: $ENVIRONMENT"
        echo "Allowed values: dev, qa, stage, prod"
        exit 1
        ;;
esac

export ECR_REPOSITORY

echo "=========================================="
echo "Environment Configuration"
echo "=========================================="
echo "Environment     : $ENVIRONMENT"
echo "AWS Region      : $AWS_REGION"
echo "ECR Repository  : $ECR_REPOSITORY"
echo "EKS Cluster     : ${EKS_PROJECT_NAME}-${ENVIRONMENT}"
echo "Namespace       : ${K8S_NAMESPACE}"
echo "=========================================="

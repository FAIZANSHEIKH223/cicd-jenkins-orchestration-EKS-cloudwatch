#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"

if [[ -z "$ENVIRONMENT" ]]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

CLUSTER_NAME="${EKS_PROJECT_NAME}-${ENVIRONMENT}"

echo "=========================================="
echo "Configuring kubectl"
echo "=========================================="
echo "Cluster: $CLUSTER_NAME"
echo "Region : $AWS_REGION"
echo "=========================================="

aws eks update-kubeconfig \
    --region "$AWS_REGION" \
    --name "$CLUSTER_NAME"

echo "Verifying EKS access..."

kubectl cluster-info

echo "EKS access configured successfully."

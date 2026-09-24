#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"

AWS_REGION="${AWS_REGION:-us-east-1}"
EKS_PROJECT_NAME="${EKS_PROJECT_NAME:-practice1}"

if [[ -z "${ENVIRONMENT}" ]]; then
    echo "ERROR: Environment was not provided."
    echo "Usage: ./scripts/cloudwatch-configure.sh <dev|qa|stage|prod>"
    exit 1
fi

case "${ENVIRONMENT}" in
    dev|qa|stage|prod)
        ;;
    *)
        echo "ERROR: Invalid environment: ${ENVIRONMENT}"
        echo "Allowed environments: dev, qa, stage, prod"
        exit 1
        ;;
esac

CLUSTER_NAME="${EKS_PROJECT_NAME}-${ENVIRONMENT}"
ADDON_NAME="amazon-cloudwatch-observability"

echo "=============================================================="
echo "          CLOUDWATCH OBSERVABILITY CONFIGURATION"
echo "=============================================================="
echo "Environment : ${ENVIRONMENT}"
echo "Cluster     : ${CLUSTER_NAME}"
echo "Region      : ${AWS_REGION}"
echo "Add-on      : ${ADDON_NAME}"
echo "=============================================================="

echo ""
echo "Checking AWS identity..."

aws sts get-caller-identity

echo ""
echo "Checking EKS cluster..."

aws eks describe-cluster \
    --name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --query 'cluster.status' \
    --output text

echo ""
echo "Checking CloudWatch Observability add-on..."

ADDON_STATUS="$(
    aws eks describe-addon \
        --cluster-name "${CLUSTER_NAME}" \
        --addon-name "${ADDON_NAME}" \
        --region "${AWS_REGION}" \
        --query 'addon.status' \
        --output text 2>/dev/null || true
)"

if [[ -z "${ADDON_STATUS}" || "${ADDON_STATUS}" == "None" ]]; then

    echo "CloudWatch Observability add-on is not installed."
    echo "Installing add-on..."

    aws eks create-addon \
        --cluster-name "${CLUSTER_NAME}" \
        --addon-name "${ADDON_NAME}" \
        --region "${AWS_REGION}" \
        --resolve-conflicts OVERWRITE

else

    echo "CloudWatch Observability add-on already exists."
    echo "Current status: ${ADDON_STATUS}"

fi

echo ""
echo "Waiting for CloudWatch Observability add-on..."

aws eks wait addon-active \
    --cluster-name "${CLUSTER_NAME}" \
    --addon-name "${ADDON_NAME}" \
    --region "${AWS_REGION}"

echo ""
echo "CloudWatch Observability add-on is ACTIVE."

echo ""
echo "Checking add-on details..."

aws eks describe-addon \
    --cluster-name "${CLUSTER_NAME}" \
    --addon-name "${ADDON_NAME}" \
    --region "${AWS_REGION}" \
    --query 'addon.{Name:addonName,Status:status,Version:addonVersion}' \
    --output table

echo ""
echo "Checking CloudWatch namespace..."

kubectl get namespace amazon-cloudwatch \
    --ignore-not-found=true

echo ""
echo "Checking CloudWatch pods..."

kubectl get pods \
    -n amazon-cloudwatch \
    -o wide || true

echo ""
echo "=============================================================="
echo "       CLOUDWATCH CONFIGURATION COMPLETED"
echo "=============================================================="
echo "Cluster : ${CLUSTER_NAME}"
echo "Region  : ${AWS_REGION}"
echo "Add-on  : ${ADDON_NAME}"
echo "=============================================================="

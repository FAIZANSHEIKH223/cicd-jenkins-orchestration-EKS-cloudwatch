#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"

if [[ -z "$ENVIRONMENT" ]]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

TERRAFORM_ENV_DIR="${TERRAFORM_DIR}/environments/${ENVIRONMENT}"

if [[ ! -d "$TERRAFORM_ENV_DIR" ]]; then
    echo "ERROR: Terraform environment directory not found:"
    echo "$TERRAFORM_ENV_DIR"
    exit 1
fi

cd "$TERRAFORM_ENV_DIR"

echo "=========================================="
echo "Terraform Init"
echo "=========================================="

terraform init \
    -input=false

echo "=========================================="
echo "Terraform Format Check"
echo "=========================================="

terraform fmt -check

echo "=========================================="
echo "Terraform Validate"
echo "=========================================="

terraform validate

echo "=========================================="
echo "Terraform Plan"
echo "=========================================="

terraform plan \
    -input=false \
    -out="tfplan"

echo "Terraform plan completed."

ls -lh tfplan

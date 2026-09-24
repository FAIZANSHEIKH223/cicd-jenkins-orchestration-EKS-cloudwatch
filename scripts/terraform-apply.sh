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
echo "Terraform Apply"
echo "=========================================="

if [[ ! -f tfplan ]]; then
    echo "No existing Terraform plan found."
    echo "Creating a new plan..."

    terraform init \
        -input=false

    terraform plan \
        -input=false \
        -out="tfplan"
fi

terraform apply \
    -input=false \
    -auto-approve \
    tfplan

echo "=========================================="
echo "Terraform Apply Completed"
echo "=========================================="

terraform output

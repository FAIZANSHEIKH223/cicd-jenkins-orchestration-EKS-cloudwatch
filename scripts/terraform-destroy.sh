#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"

if [[ -z "${ENVIRONMENT}" ]]; then
    echo "ERROR: Environment was not provided."
    echo "Usage: ./scripts/terraform-destroy.sh <dev|qa|stage|prod>"
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

TERRAFORM_DIR="${WORKSPACE:-$(pwd)}/terraform-infrastructure"
ENVIRONMENT_DIR="${TERRAFORM_DIR}/environments/${ENVIRONMENT}"

if [[ ! -d "${TERRAFORM_DIR}" ]]; then
    echo "ERROR: Terraform directory not found:"
    echo "${TERRAFORM_DIR}"
    exit 1
fi

if [[ ! -d "${ENVIRONMENT_DIR}" ]]; then
    echo "ERROR: Terraform environment directory not found:"
    echo "${ENVIRONMENT_DIR}"
    exit 1
fi

cd "${ENVIRONMENT_DIR}"

echo "=============================================="
echo "Terraform Destroy"
echo "=============================================="
echo "Environment : ${ENVIRONMENT}"
echo "Directory   : ${ENVIRONMENT_DIR}"
echo "AWS Region  : ${AWS_REGION:-us-east-1}"
echo "=============================================="

echo ""
echo "Checking Terraform version..."
terraform version

echo ""
echo "Initializing Terraform..."
terraform init -input=false

echo ""
echo "Formatting Terraform configuration..."
terraform fmt -check -recursive "${TERRAFORM_DIR}"

echo ""
echo "Validating Terraform configuration..."
terraform validate

echo ""
echo "Creating Terraform destroy plan..."
terraform plan \
    -destroy \
    -input=false \
    -out=destroy.tfplan

echo ""
echo "=============================================="
echo "Destroy plan created successfully."
echo "=============================================="

echo ""
echo "The following command will destroy the resources:"
echo ""
echo "terraform apply -input=false destroy.tfplan"
echo ""

if [[ "${CONFIRM_DESTROY:-}" != "DESTROY" ]]; then
    echo "Destroy confirmation was not provided."
    echo "Set CONFIRM_DESTROY=DESTROY to continue."
    echo ""
    echo "Destroy plan has NOT been applied."
    exit 1
fi

echo ""
echo "CONFIRM_DESTROY=DESTROY detected."
echo "Applying destroy plan..."

terraform apply \
    -input=false \
    destroy.tfplan

echo ""
echo "=============================================="
echo "Terraform destroy completed successfully."
echo "=============================================="
echo "Environment: ${ENVIRONMENT}"
echo "=============================================="

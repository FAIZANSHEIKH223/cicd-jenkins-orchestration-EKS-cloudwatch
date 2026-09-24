#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"
BUILD_NUMBER="${2:-}"

if [[ -z "$ENVIRONMENT" || -z "$BUILD_NUMBER" ]]; then
    echo "Usage: $0 <environment> <build-number>"
    exit 1
fi

IMAGE_NAME="practice1:${BUILD_NUMBER}"

echo "=========================================="
echo "Docker Build"
echo "=========================================="
echo "Environment : $ENVIRONMENT"
echo "Image       : $IMAGE_NAME"
echo "=========================================="

cd "$APPLICATION_DIR"

if [[ ! -f Dockerfile ]]; then
    echo "ERROR: Dockerfile not found in application repository."
    exit 1
fi

docker build \
    --pull \
    -t "$IMAGE_NAME" \
    .

echo "Docker image created successfully."

docker images "$IMAGE_NAME"

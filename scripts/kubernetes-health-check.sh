#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"

if [[ -z "$ENVIRONMENT" ]]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

echo "=========================================="
echo "Kubernetes Health Check"
echo "=========================================="

echo "Deployment status:"

kubectl rollout status \
    deployment/"$K8S_DEPLOYMENT" \
    -n "$K8S_NAMESPACE" \
    --timeout=5m

echo
echo "Pods:"

kubectl get pods \
    -n "$K8S_NAMESPACE" \
    -o wide

echo
echo "Deployment:"

kubectl get deployment \
    "$K8S_DEPLOYMENT" \
    -n "$K8S_NAMESPACE"

echo
echo "Service:"

kubectl get service \
    "$K8S_SERVICE" \
    -n "$K8S_NAMESPACE"

echo
echo "Endpoints:"

kubectl get endpoints \
    "$K8S_SERVICE" \
    -n "$K8S_NAMESPACE"

echo
echo "Checking ready replicas..."

READY_REPLICAS=$(kubectl get deployment \
    "$K8S_DEPLOYMENT" \
    -n "$K8S_NAMESPACE" \
    -o jsonpath='{.status.readyReplicas}')

DESIRED_REPLICAS=$(kubectl get deployment \
    "$K8S_DEPLOYMENT" \
    -n "$K8S_NAMESPACE" \
    -o jsonpath='{.spec.replicas}')

READY_REPLICAS="${READY_REPLICAS:-0}"

echo "Desired replicas: $DESIRED_REPLICAS"
echo "Ready replicas  : $READY_REPLICAS"

if [[ "$READY_REPLICAS" != "$DESIRED_REPLICAS" ]]; then
    echo "ERROR: Not all replicas are ready."
    exit 1
fi

echo
echo "Checking service LoadBalancer..."

EXTERNAL_HOSTNAME=""

for i in {1..30}; do

    EXTERNAL_HOSTNAME=$(kubectl get service \
        "$K8S_SERVICE" \
        -n "$K8S_NAMESPACE" \
        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)

    if [[ -n "$EXTERNAL_HOSTNAME" ]]; then
        break
    fi

    echo "Waiting for LoadBalancer address... attempt $i/30"

    sleep 10

done

if [[ -z "$EXTERNAL_HOSTNAME" ]]; then
    echo "ERROR: LoadBalancer hostname was not assigned."
    exit 1
fi

echo
echo "=========================================="
echo "APPLICATION LOAD BALANCER"
echo "=========================================="
echo "Hostname:"
echo "$EXTERNAL_HOSTNAME"
echo
echo "Application URL:"
echo "http://${EXTERNAL_HOSTNAME}"
echo "=========================================="

echo "Kubernetes health check completed successfully."

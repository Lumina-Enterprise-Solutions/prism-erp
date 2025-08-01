#!/bin/bash
# scripts/setup-cluster.sh

set -euo pipefail

CLUSTER_NAME="prism-dev"
CLUSTER_CONFIG="deployments/kind/cluster-config.yaml"

# Check if cluster already exists
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "Cluster ${CLUSTER_NAME} already exists. Deleting..."
    kind delete cluster --name ${CLUSTER_NAME}
fi

# Create cluster
echo "Creating kind cluster..."
kind create cluster --config=${CLUSTER_CONFIG}

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready node --all --timeout=60s

# Create namespace
kubectl create namespace prism-dev

echo "✅ Kind cluster '${CLUSTER_NAME}' created successfully!"

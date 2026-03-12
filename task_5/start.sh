#!/bin/bash
set -e

NAMESPACE=task5

echo "=== [1] Create namespace ==="
kubectl create namespace ${NAMESPACE} || true
kubectl config set-context --current --namespace=${NAMESPACE}

echo "=== [2] Apply network policies ==="
kubectl apply -f default-deny-all.yaml
kubectl apply -f allow-dns.yaml
kubectl apply -f non-admin-api-allow.yaml
kubectl apply -f admin-api-allow.yaml

echo "=== [3] Deploy services ==="

kubectl run front-end-app \
  --image=nginx \
  --labels role=front-end \
  --expose --port 80

kubectl run back-end-api-app \
  --image=nginx \
  --labels role=back-end-api \
  --expose --port 80

kubectl run admin-front-end-app \
  --image=nginx \
  --labels role=admin-front-end \
  --expose --port 80

kubectl run admin-back-end-api-app \
  --image=nginx \
  --labels role=admin-back-end-api \
  --expose --port 80

echo "=== [4] Waiting for pods to be ready ==="
kubectl wait --for=condition=Ready pod --all --timeout=120s

echo "=== [5] Testing connectivity ==="

echo "--- front-end -> back-end-api (should PASS) ---"
kubectl exec front-end-app -- wget -qO- --timeout=2 http://back-end-api-app || echo "BLOCKED"

echo "--- admin-front-end -> admin-back-end-api (should PASS) ---"
kubectl exec admin-front-end-app -- wget -qO- --timeout=2 http://admin-back-end-api-app || echo "BLOCKED"

echo "--- front-end -> admin-back-end-api (should FAIL) ---"
kubectl exec front-end-app -- wget -qO- --timeout=2 http://admin-back-end-api-app || echo "BLOCKED (expected)"

echo "--- admin-front-end -> back-end-api (should FAIL) ---"
kubectl exec admin-front-end-app -- wget -qO- --timeout=2 http://back-end-api-app || echo "BLOCKED (expected)"

echo "=== DONE ==="
echo "Namespace: ${NAMESPACE}"
#!/usr/bin/env bash
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0
#
# Applies k8s/ in dependency order:
#   namespace -> storage class -> config/secrets -> PVCs -> stateful datastores ->
#   telemetry backends -> otel-collector -> flagd -> platform services ->
#   mid-tier -> checkout -> frontend tier -> edge (frontend-proxy)
#
# Each stage is applied, then the script waits for that stage's Deployments/
# StatefulSets to report Ready before moving on - so a stage's dependencies
# are verifiably running (not just "kubectl apply has been called on them")
# before the next stage, which depends on them, is applied.
set -euo pipefail

NS=otel-demo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMEOUT=${WAIT_TIMEOUT:-300s}

wait_stage() {
  # Wait on every Deployment/StatefulSet currently in the namespace (cheap - each
  # stage only just added its own), rather than trying to name them individually.
  mapfile -t deploys < <(kubectl -n "$NS" get deployment -o name 2>/dev/null || true)
  for d in "${deploys[@]:-}"; do
    [ -z "$d" ] && continue
    echo "  waiting on $d ..."
    kubectl -n "$NS" rollout status "$d" --timeout="$TIMEOUT"
  done
  mapfile -t statefulsets < <(kubectl -n "$NS" get statefulset -o name 2>/dev/null || true)
  for d in "${statefulsets[@]:-}"; do
    [ -z "$d" ] && continue
    echo "  waiting on $d ..."
    kubectl -n "$NS" rollout status "$d" --timeout="$TIMEOUT"
  done
}

apply_stage() {
  local dir="$1"
  echo "==> applying $dir"
  kubectl apply -f "$SCRIPT_DIR/$dir/"
  wait_stage "$dir"
}

echo "==> namespace"
kubectl apply -f "$SCRIPT_DIR/00-namespace/"

echo "==> storage class"
kubectl apply -f "$SCRIPT_DIR/01-storage/storageclass.yaml"
# 01-storage/pv-postgres-static-example.yaml is intentionally NOT applied here -
# it is an opt-in alternative to dynamic provisioning, see the comments in that file.

echo "==> config + secrets"
kubectl apply -f "$SCRIPT_DIR/02-config/"
echo "    creating grafana-alerting and grafana-dashboards-json ConfigMaps"
echo "    (too large to hand-author as static YAML - generated from the repo tree)"
kubectl create configmap grafana-alerting -n "$NS" \
  --from-file="$SCRIPT_DIR/../src/grafana/provisioning/alerting" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl create configmap grafana-dashboards-json -n "$NS" \
  --from-file="$SCRIPT_DIR/../src/grafana/provisioning/dashboards/demo" \
  --dry-run=client -o yaml | kubectl apply -f -

apply_stage 03-pvc
apply_stage 04-datastores
apply_stage 05-telemetry-backends
apply_stage 06-otel-collector
apply_stage 07-flagd
apply_stage 08-platform-services
apply_stage 09-mid-tier
apply_stage 10-checkout
apply_stage 11-frontend-tier
apply_stage 12-edge

echo "==> done. Frontend-proxy external address:"
kubectl -n "$NS" get svc frontend-proxy

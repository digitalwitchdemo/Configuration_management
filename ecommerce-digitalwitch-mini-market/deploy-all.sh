#!/usr/bin/env bash
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0
#
# Fast path: applies every module in order, waiting for each one's
# Deployments/StatefulSets to report Ready before moving to the next.
#
# This is for re-deploying the whole platform quickly once you already
# understand each module from doing them by hand - it is NOT the intended
# way to learn this project the first time. See README.md: deploy each
# numbered module yourself, read its README, and run its verify commands
# before moving to the next one.
set -euo pipefail

NS=digitalwitch-market
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMEOUT=${WAIT_TIMEOUT:-300s}

MODULES=(
  01-foundation
  02-configuration
  03-databases
  04-kafka
  05-observability-backends
  06-telemetry-collector
  07-feature-flags
  08-core-services
  09-storefront
  10-ai-assistant
)

wait_for_workloads() {
  for kind in deployment statefulset; do
    mapfile -t names < <(kubectl -n "$NS" get "$kind" -o name 2>/dev/null || true)
    for n in "${names[@]:-}"; do
      [ -z "$n" ] && continue
      echo "  waiting on $n ..."
      kubectl -n "$NS" rollout status "$n" --timeout="$TIMEOUT"
    done
  done
}

for module in "${MODULES[@]}"; do
  echo "==> Module: $module"
  kubectl apply -f "$SCRIPT_DIR/$module/"
  wait_for_workloads
done

echo
echo "==> All 10 modules deployed. Storefront address:"
kubectl -n "$NS" get svc frontend-proxy
echo
echo "==> Chatbot is at the same address, path /chatbot"

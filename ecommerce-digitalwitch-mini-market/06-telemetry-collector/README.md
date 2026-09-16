# Module 06 — Telemetry Collector

**Goal:** deploy the one service every other service in modules 08–10 will
send its telemetry to — the OpenTelemetry Collector.

## What's in this module

| File | What it deploys |
|---|---|
| `deployment-otel-collector.yaml` | **otel-collector** — receives OTLP traffic on ports 4317 (gRPC) and 4318 (HTTP), and exports it out to the four backends from module 05. |

## Why every service points here instead of straight at Jaeger/Prometheus

Without a collector, every one of the ~25 business services would need to
know Jaeger's address, Prometheus's address, and OpenSearch's address, and
would need its own retry/batching logic for each. With a collector, every
service knows exactly **one** address —
`OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317` — and the
collector alone knows how to fan that out to traces→Jaeger,
metrics→Prometheus, logs→OpenSearch. Swap a backend later and you edit the
collector's config in one place, not 25 services.

This is why module 05 came *before* this one: the collector's config
(`otel-collector-config` ConfigMap, from module 02) already lists Jaeger,
OpenSearch and the OpAMP server as export targets, and it needs to reach
them to start cleanly.

## Deploy it

```bash
kubectl apply -f .
```

## Verify

```bash
kubectl get pods -n digitalwitch-market -l app.kubernetes.io/name=otel-collector
kubectl logs -n digitalwitch-market -l app.kubernetes.io/name=otel-collector --tail=50
```

Pod should be `1/1 Running`. In the logs, you'll see a handful of errors
about `docker_stats` and `host_metrics` receivers failing — that's expected
and harmless (they're written for a Docker host, not Kubernetes; see the
top-level README). What you should **not** see is anything about failing to
connect to Jaeger or the OpAMP server — if you do, go back and confirm
module 05's pods are actually Running first.

## Next

[Module 07 — Feature Flags](../07-feature-flags/)

# Module 05 — Observability Backends

**Goal:** deploy the four places telemetry data actually lives, *before* the
collector that feeds them (module 06). The collector needs somewhere to
export to — deploy the destinations first, then the pipe.

## What's in this module

| File | What it deploys | Stores |
|---|---|---|
| `deployment-jaeger.yaml` | **Jaeger** | Distributed traces — the path a single request took through every service it touched. |
| `pvc-prometheus-data.yaml` + `deployment-prometheus.yaml` | **Prometheus** | Metrics — counters and histograms over time (request rates, error rates, queue depth). |
| `pvc-opensearch-data.yaml` + `deployment-opensearch.yaml` | **OpenSearch** | Logs. |
| `pvc-grafana-data.yaml` + `deployment-grafana.yaml` | **Grafana** | Dashboards that *query* the three stores above — it doesn't store telemetry itself. |
| `deployment-opamp-server.yaml` | **OpAMP server** | A small control-plane service the collector (and a few app services) check in with for remote config. Not on the request path; deployed here because the collector waits on it. |

These four kinds of telemetry — traces, metrics, logs, plus dashboards over
all three — are the four pillars you'll hear about constantly in
observability work. This module is where each one gets a concrete home.

## Deploy it

```bash
kubectl apply -f .
```

## Verify

```bash
kubectl get pods -n digitalwitch-market \
  -l 'app.kubernetes.io/name in (jaeger,prometheus,opensearch,grafana,opamp-server)'
```

All five should reach `1/1 Running`. OpenSearch is the slowest — it's a JVM
doing cluster bootstrap — give it a minute or two before worrying. Peek at
its health directly:

```bash
kubectl exec -n digitalwitch-market deploy/opensearch -- \
  curl -s http://localhost:9200/_cluster/health
```

Look for `"status":"green"` or `"status":"yellow"` (both are fine for a
single-node cluster — `"red"` means something's actually wrong).

There is nothing to *see* in Jaeger, Prometheus or Grafana's UI yet — no
service is sending them data until module 06 deploys the collector. That's
expected; you're checking that the destinations exist and are healthy, not
that they have data in them.

## Next

[Module 06 — Telemetry Collector](../06-telemetry-collector/)

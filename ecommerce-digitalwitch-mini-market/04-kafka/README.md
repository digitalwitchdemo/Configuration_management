# Module 04 — Kafka & Event-Driven Services

**Goal:** stand up the message broker, then immediately deploy the two
services that only exist to *consume* from it — so the concept "a producer
and a consumer never talk to each other directly" clicks right away instead
of being explained in the abstract.

## What's in this module

| File | What it deploys | Role |
|---|---|---|
| `pvc-kafka-data.yaml` + `statefulset-kafka.yaml` | **kafka** — a `StatefulSet` (it's a database of a kind: a durable, ordered log) | The event bus. `checkout` (module 09) publishes an "order placed" event here; nothing downstream calls checkout back. |
| `deployment-accounting.yaml` | **accounting** | Consumes order events, writes order/shipping/line-item records into `astronomy-db` (module 03). |
| `deployment-fraud-detection.yaml` | **fraud-detection** | Consumes the *same* order events independently, for fraud scoring. |

## Why accounting and fraud-detection live here, not in module 08

They're ordinary business services in every other sense — but architecturally
their entire job is "listen to Kafka," and putting them next to Kafka means
you deploy the producer's-eye view (a topic, waiting for readers) and the
consumer's-eye view (two independent readers of the same topic) in the same
five minutes. That's the actual lesson of this module: one event, many
independent consumers, no direct coupling between them.

## Deploy it

```bash
kubectl apply -f .
```

## Verify

```bash
kubectl get pods -n digitalwitch-market -l 'app.kubernetes.io/name in (kafka,accounting,fraud-detection)'
```

`accounting` and `fraud-detection` have no health probe of their own (they
don't serve traffic — there's nothing to probe), so `1/1 Running` and no
recent restarts is what "healthy" looks like for them. Confirm Kafka is
actually reachable, not just Running:

```bash
kubectl exec -n digitalwitch-market -it statefulset/kafka -- \
  /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list
```

You won't see the `orders` topic yet — it's created automatically the first
time `checkout` (module 09) publishes to it. Seeing this command connect at
all (rather than time out) confirms Kafka itself is up.

## Next

[Module 05 — Observability Backends](../05-observability-backends/)

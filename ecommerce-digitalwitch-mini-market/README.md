# Ecommerce-DigitalWitch Mini-Market Platform

A Kubernetes deployment of a working e-commerce platform, split into **10 numbered
modules** you deploy one at a time — infrastructure first, then data, then
messaging, then observability, then the application itself, and the AI
shopping assistant last. Built for the DigitalWitch DevOps internship: each
module is small enough to read in full, deploy in a few minutes, and verify
before moving on.

> Under the hood this runs the [OpenTelemetry Demo](https://opentelemetry.io/docs/demo/)
> ("Astronomy Shop") — a real, actively-maintained microservices app, not a toy —
> renamed and reorganized here for teaching.

## How this is organized

Every module is its own folder with its own `README.md` and its own YAML files.
The pattern is **always the same**, on purpose:

```bash
cd 0X-module-name
cat README.md          # read what you're about to deploy, and why
kubectl apply -f .     # deploy everything in this module
# ...run the verify command the README gives you...
cd ../0(X+1)-next-module
```

Same command, every module, ten times. Once it clicks on module 3, you don't
relearn it for module 9.

## Modules, in order

| # | Module | What it deploys | Why it comes here |
|---|---|---|---|
| 01 | [`01-foundation`](01-foundation/) | Namespace, StorageClass | Everything else lives inside this namespace and provisions storage from this class. |
| 02 | [`02-configuration`](02-configuration/) | ConfigMaps, Secrets | Every service reads its settings from here — deploy it before anything that needs it. |
| 03 | [`03-databases`](03-databases/) | Postgres, Valkey | The platform's two datastores. Nothing else can start correctly without them. |
| 04 | [`04-kafka`](04-kafka/) | Kafka, accounting, fraud-detection | The event bus, plus the two services that consume order events from it. |
| 05 | [`05-observability-backends`](05-observability-backends/) | Jaeger, Prometheus, OpenSearch, Grafana, OpAMP server | Where telemetry data actually lands. Deployed *before* the collector, which needs them running to export to. |
| 06 | [`06-telemetry-collector`](06-telemetry-collector/) | otel-collector | The single door every other service's telemetry walks through. |
| 07 | [`07-feature-flags`](07-feature-flags/) | flagd, flagd-ui | Feature flags used across the business services — deployed before them. |
| 08 | [`08-core-services`](08-core-services/) | ad, cart, currency, email, image-provider, payment, product-catalog, quote, recommendation, shipping, telemetry-docs | The 11 "boring" business microservices the storefront is built from. |
| 09 | [`09-storefront`](09-storefront/) | checkout, frontend, frontend-proxy, load-generator | The application itself: the storefront UI, checkout flow, and the public entry point. |
| 10 | [`10-ai-assistant`](10-ai-assistant/) | mcp, agent, chatbot | The AI shopping assistant, added **last**, on top of an already-working platform. |

This is the same order as the [architecture diagram](ARCHITECTURE.md) your
trainer walked through: infrastructure → data → messaging → observability →
the app → the AI layer on top.

## Before you start

- A Kubernetes cluster you can `kubectl apply` to, with the **AWS EBS CSI
  driver** installed (module 01's StorageClass uses `ebs.csi.aws.com`) — ask
  your trainer if you're not sure this is set up.
- `kubectl` configured against that cluster.
- Container images: the custom-built services use ECR placeholders
  (`<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/ecomerce/<service>:latest`)
  — your trainer will give you the real registry to substitute, e.g.:
  ```bash
  grep -rl 'AWS_ACCOUNT_ID' . | xargs sed -i 's/<AWS_ACCOUNT_ID>/123456789012/g; s/<AWS_REGION>/us-east-1/g'
  ```

## If you deploy something out of order

Try it — it's a safe way to learn. Every service's pod waits, in an
`Init:0/1` state, for its real dependencies to answer on the network before
its main container even starts. Run:

```bash
kubectl -n digitalwitch-market describe pod <pod-name>
```

and the `wait-for-deps` init container's log will tell you exactly which
service it's still waiting on. Nothing crash-loops or fails mysteriously —
it just waits, visibly, until you deploy the module it needs.

## Fast path (for demos, not for learning)

`deploy-all.sh` applies every module in order and waits for each one to
report Ready before moving to the next — useful once you've done the modules
by hand and want to redeploy the whole thing in one go.

## Known simplifications

- `bootstrap.memory_lock` is off for OpenSearch so it runs without extra
  node privileges.
- `otel-collector`'s Docker-only receivers (`docker_stats`, `host_metrics`)
  are left in its config for fidelity with the source project but will just
  fail to scrape on Kubernetes — harmless.
- `flagd-ui` can't persist flag edits across a restart (its config comes
  from a read-only ConfigMap) — ask your trainer if this matters for your
  exercise.
- One static-`PersistentVolume` example lives in `01-foundation/` for
  reference; it isn't applied by `deploy-all.sh` — the StorageClass provisions
  everything dynamically by default.
